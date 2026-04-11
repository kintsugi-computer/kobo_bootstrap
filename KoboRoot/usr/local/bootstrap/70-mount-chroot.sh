#!/bin/sh

# Mount the chroot partition from the external microSD
# Create the rootfs if it does not yet exist by unpacking an Alpine minirootfs

# load the functions logmsg, start_network and stop_network
source /usr/local/bootstrap/bootstrap-functions.sh

CHROOT_MNT="/mnt/chroot"
EXTERNAL_SD="/dev/mmcblk1"
ROOTFS="${CHROOT_MNT}/rootfs"

MINIROOTFS="alpine-minirootfs-3.23.3-armhf.tar.gz"
MINIROOTFS_URL="https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/armhf"
CHROOT_SCRIPTS="kobo_chroot_v0.0.2.tgz"
CHROOT_SCRIPTS_URL="https://github.com/kintsugi-computer/kobo_chroot_scripts/releases/download/v0.0.2"


if [ -e "${EXTERNAL_SD}" ]; then
    LINUX_PARTITION="$(/sbin/fdisk -l "${EXTERNAL_SD}" | /bin/grep Linux | /usr/bin/cut -f1 -d' ')"

    for partition in ${LINUX_PARTITION}; do
        /bin/mkdir -p "${CHROOT_MNT}"
        /bin/mount -o noatime,nodiratime "${partition}" "${CHROOT_MNT}" 
        break
    done

    if /bin/mountpoint "${CHROOT_MNT}" && [ ! -e "${ROOTFS}" ]; then
        started_network=start_network
        /usr/bin/wget -O "${CHROOT_MNT}/${MINIROOTFS}" "${MINIROOTFS_URL}/${MINIROOTFS}"
        /bin/mkdir -p "${ROOTFS}"
        /bin/tar -C "${ROOTFS}" -zxf "${CHROOT_MNT}/${MINIROOTFS}"
        /usr/bin/wget -O "${CHROOT_MNT}/${CHROOT_SCRIPTS}" "${CHROOT_SCRIPTS_URL}/${CHROOT_SCRIPTS}"
        /bin/tar -C "${CHROOT_MNT}" -zxf "${CHROOT_MNT}/${CHROOT_SCRIPTS}"
        stop_network "${started_network}"
    fi
fi
