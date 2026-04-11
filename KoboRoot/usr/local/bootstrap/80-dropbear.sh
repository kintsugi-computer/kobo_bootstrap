#!/bin/sh

# Enable the function logmsg, start_network and stop_network
source /usr/local/bootstrap/bootstrap-functions.sh

rootfs="/mnt/chroot/rootfs"
run_chroot="/mnt/chroot/run_chroot.sh"

if [ -d "${rootfs}" ]; then
    if [ ! -e  "${rootfs}/usr/sbin/dropbear" -o ! -e  "${rootfs}/usr/lib/ssh/sftp-server" ]; then
        network_started=start_network
        if [ ! -e  "${rootfs}/usr/sbin/dropbear" ]; then
            [ -e "${run_chroot}" ] && "${run_chroot}" apk add dropbear
        fi
        if [ ! -e  "${rootfs}/usr/lib/ssh/sftp-server" ]; then
            [ -e "${run_chroot}" ] && "${run_chroot}" apk add openssh-sftp-server
        fi
        stop_network "${network_started}"
    fi
    [ -e "${run_chroot}" ] && echo "root:koboroot" | "${run_chroot}" /usr/sbin/chpasswd
    [ -e "${run_chroot}" ] && "${run_chroot}" /usr/sbin/dropbear -RB
fi

