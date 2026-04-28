#!/bin/sh

# Mount the chroot partition from the external microSD
# Create the rootfs if it does not yet exist by unpacking an Alpine minirootfs

# load the functions logmsg, start_network and stop_network
source /usr/local/bootstrap/bootstrap-functions.sh

CHROOT_MNT="/mnt/chroot"
EXTERNAL_SD="/dev/mmcblk1"
ROOTFS="${CHROOT_MNT}/rootfs"
MOUNT_CHROOT="${CHROOT_MNT}/bin/mount_chroot.sh"
UNMOUNT_CHROOT="${CHROOT_MNT}/bin/unmount_chroot.sh"

ALPINE_RELEASE=3.22
ALPINE_REVISION=4

MINIROOTFS="alpine-minirootfs-${ALPINE_RELEASE}.${ALPINE_REVISION}-armhf.tar.gz"
MINIROOTFS_URL="https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_RELEASE}/releases/armhf"
CHROOT_SCRIPTS_LATEST="https://api.github.com/repos/kintsugi-computer/kobo_chroot_scripts/releases/latest"
CHROOT_SCRIPTS_URL=""

if [ "${1}" == "shutdown" ]; then
  if [ -x "${UNMOUNT_CHROOT}" -a -e "${ROOTFS}" ]; then
    if mountpoint "${ROOTFS}/dev"; then
      logmsg "-- Unmounting chroot filesystems"
      ${UNMOUNT_CHROOT}
    fi
  fi
  exit
fi

if [ -e "${EXTERNAL_SD}" ]; then
  logmsg "-- External SD present as ${EXTERNAL_SD}"
  LINUX_PARTITION="$(/sbin/fdisk -l "${EXTERNAL_SD}" | /bin/grep Linux | /usr/bin/cut -f1 -d' ')"

  logmsg "-- Found Linux partition(s) at ${LINUX_PARTITION}"
  if /bin/mountpoint "${CHROOT_MNT}"; then
    logmsg "-- Partition already mounted at ${CHROOT_MNT}"
  else
    for partition in ${LINUX_PARTITION}; do
      /bin/mkdir -p "${CHROOT_MNT}"
      /bin/mount -o noatime,nodiratime "${partition}" "${CHROOT_MNT}" 
      logmsg "-- Mounted Linux partition ${partition} at ${CHROOT_MNT}"
      break
    done
  fi

  if /bin/mountpoint "${CHROOT_MNT}"; then
    if [ ! -e "${ROOTFS}" ]; then
      logmsg "-- ${ROOTFS} not present"

      if start_network; then

        waittime=10
        while [ "${waittime}" -gt 0 -a -z "${CHROOT_SCRIPTS_URL}" ]; do
          sleep 3
          logmsg "-- Downloading ${CHROOT_SCRIPTS_LATEST}: $((--waittime))"
          CHROOT_SCRIPTS_URL="$(/usr/bin/wget -O - "${CHROOT_SCRIPTS_LATEST}" | /bin/sed -n 's/.*browser_download_url": "\(.*\)"/\1/p')"
        done

        if [ -z "${CHROOT_SCRIPTS_URL}" ]; then
          logmsg "-- Download of ${CHROOT_SCRIPTS_LATEST} failed"
          exit 1
        fi

        CHROOT_SCRIPTS_TGZ="$(basename "${CHROOT_SCRIPTS_URL}")"
        waittime=10
        while [ "${waittime}" -gt 0 -a ! -e "${CHROOT_MNT}/${CHROOT_SCRIPTS_TGZ}" ]; do
          sleep 1
          logmsg "-- Downloading ${CHROOT_SCRIPTS_URL}: $((--waittime ))"
          /usr/bin/wget -O "${CHROOT_MNT}/${CHROOT_SCRIPTS_TGZ}" "${CHROOT_SCRIPTS_URL}"
        done

        if [ ! -e "${CHROOT_MNT}/${CHROOT_SCRIPTS_TGZ}" ]; then
          logmsg "-- Download of ${CHROOT_SCRIPTS_URL} failed"
          exit 1
        fi

        logmsg "-- Unpacking ${CHROOT_SCRIPTS_TGZ}"
        /bin/tar -C "${CHROOT_MNT}" -zxf "${CHROOT_MNT}/${CHROOT_SCRIPTS_TGZ}"

        logmsg "-- Downloading ${MINIROOTFS}"
        /usr/bin/wget -P "${CHROOT_MNT}" "${MINIROOTFS_URL}/${MINIROOTFS}"
        if [ ! -e "${CHROOT_MNT}/${MINIROOTFS}" ]; then
          logmsg "-- Download of ${MINIROOTFS} failed"
          exit 1
        fi
        /bin/mkdir -p "${ROOTFS}"

        logmsg "-- Unpacking ${MINIROOTFS}"
        /bin/tar -C "${ROOTFS}" -zxf "${CHROOT_MNT}/${MINIROOTFS}"
      fi
	fi
  else
    logmsg "-- No filesystem mounted at ${CHROOT_MNT}"
  fi

  if [ -x "${MOUNT_CHROOT}" -a -e "${ROOTFS}" ]; then
    if mountpoint "${ROOTFS}/dev"; then
      logmsg "-- chroot filesystems already mounted"
    else
      logmsg "-- Mounting chroot filesystems"
      ${MOUNT_CHROOT}
    fi
  fi
else
  logmsg "-- No external SD present"
fi
