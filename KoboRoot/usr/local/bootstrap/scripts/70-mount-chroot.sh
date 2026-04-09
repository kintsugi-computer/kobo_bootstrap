#!/bin/sh

# Mount the chroot partition from the external microSD
# Create the rootfs if it does not yet exist by unpacking an Alpine minirootfs

CHROOT_MNT="/mnt/chroot"
EXTERNAL_SD="/dev/mmcblk1"
ROOTFS="${CHROOT_MNT}/rootfs"

MINIROOTFS="alpine-minirootfs-3.23.3-armhf.tar.gz"
MINIROOTFS_URL="https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/armhf"
CHROOT_SCRIPT=""
CHROOT_SCRIPT_URL=""

source /usr/local/bootstrap/scripts/bootstrap-functions.sh

if [ -e "${EXTERNAL_SD}" ]; then
    LINUX_PARTITION="$(/sbin/fdisk -l "${EXTERNAL_SD}" | /bin/grep Linux | /usr/bin/cut -f1 -d' ')"

    for partition in ${LINUX_PARTITION}; do
        /bin/mkdir -p "${CHROOT_MNT}"
        /bin/mount -o noatime,nodiratime "${partition}" "${CHROOT_MNT}" 
        break
    done

    if /bin/mountpoint "${CHROOT_MNT}" && [ ! -e "${ROOTFS}" ]; then
        start_network
        /usr/bin/wget -O "${CHROOT_MNT}/${MINIROOTFS}" "${MINIROOTFS_URL}/${MINIROOTFS}"
        /usr/bin/wget -O "${CHROOT_MNT}/${CHROOT_SCRIPT}" "${CHROOT_SCRIPTS_URL}/${CHROOT_SCRIPT}"
        /bin/mkdir -p "${ROOTFS}"
        cd "${ROOTFS}"
        /bin/tar -C "${ROOTFS}" -zxf "${CHROOT_MNT}/${MINIROOTFS}"
        stop_network
    fi
fi
