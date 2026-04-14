#!/bin/sh

# Enable the function logmsg, start_network and stop_network
source /usr/local/bootstrap/bootstrap-functions.sh

rootfs="/mnt/chroot/rootfs"
run_chroot="/mnt/chroot/bin/run_chroot.sh"

if [ -d "${rootfs}" ]; then
  logmsg "-- ${rootfs} is present"

  if [ ! -e "${run_chroot}" ]; then
    logmsg "-- The command "${run_chroot}" is not present. Exiting"
    exit 1
  fi

  if [ ! -e  "${rootfs}/usr/sbin/dropbear" -o ! -e  "${rootfs}/usr/lib/ssh/sftp-server" ]; then

    if start_network; then

      if [ ! -e  "${rootfs}/usr/sbin/dropbear" ]; then
        logmsg "-- Updating root password in chroot at ${rootfs}"
        echo "root:koboroot" | "${run_chroot}" /usr/sbin/chpasswd
      fi

      waittime=10
      while [ "${waittime}" -gt 0 -a ! -e "${rootfs}/usr/sbin/dropbear" ]; do
        sleep 1
        logmsg "-- Installing dropbear in chroot at ${rootfs}: $((--waittime))"
        "${run_chroot}" /sbin/apk add dropbear
      done
      if [ ! -e  "${rootfs}/usr/sbin/dropbear" ]; then
        logmsg "-- Installation of dropbear failed"
      fi

      waittime=10
      while [ "${waittime}" -gt 0 -a ! -e "${rootfs}/usr/lib/ssh/sftp-server" ]; do
        sleep 1
        logmsg "-- Installing openssh-sftp-server in chroot at ${rootfs}: $((waittime))"
        "${run_chroot}" /sbin/apk add openssh-sftp-server
      done
      if [ ! -e  "${rootfs}/usr/lib/ssh/sftp-server" ]; then
        logmsg "-- Installation of ssh-sftp-server failed"
      fi
    else
      logmsg "-- No network available. Exiting"
      exit 1
    fi
  fi
  if [ -e  "${rootfs}/usr/sbin/dropbear" ]; then
    logmsg "-- Starting dropbear in chroot at ${rootfs}"
    "${run_chroot}" /usr/sbin/dropbear -RB
  fi
else
  logmsg "-- ${rootfs} not present"
fi

