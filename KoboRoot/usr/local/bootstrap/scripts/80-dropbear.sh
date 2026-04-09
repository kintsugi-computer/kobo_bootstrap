#!/bin/sh

rootfs="/mnt/chroot/rootfs"
run_chroot="/mnt/chroot/run_chroot.sh"

source /usr/local/bootstrap/scripts/bootstrap-functions.sh

if [ -d "${rootfs}" ]; then
    if [ ! -e  "${rootfs}/usr/sbin/dropbear" -o ! -e  "${rootfs}/usr/lib/ssh/sftp-server" ]; then
        start_network
        if [ ! -e  "${rootfs}/usr/sbin/dropbear" ]; then
            [ -e "${run_chroot}" ] && "${run_chroot}" apk add dropbear
        fi
        if [ ! -e  "${rootfs}/usr/lib/ssh/sftp-server" ]; then
            [ -e "${run_chroot}" ] && "${run_chroot}" apk add openssh-sftp-server
        fi
        stop_network
    fi
    [ -e "${run_chroot}" ] && "${run_chroot}" /usr/sbin/dropbear -RB
fi

