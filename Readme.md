# Alpine chroot for Kobo Aura

This project provides a KoboRoot.tgz update for Kobo Aura (model N514) that
creates and enables an Alpine chroot environment located on an external 
microSD card. This project is not tested on any other Kobo model.

This project would not have been realised without the inspirational work and
examples by the contributors of the Kobo Developer's Corner at www.mobileread.com.

## General

### Introduction

The open character of the Kobo Aura invites tinkering, but not everyone
is comfortable with cross-compiling software. This project adds an 
Alpine chroot to the Kobo Aura, accessible using SSH, that support 
installing software from the Alpine package repository.

This project assumes a recent version of the Kobo Aura firmware. Please
update you firmware.

Note that this project enables the Dropbear SSH server inside the
Alpine chroot. This must be disabled if you already make use of an
SSH server to access your Kobo. See below for how to do that. 

Finally, this project makes changes to the firmware of your Kobo Aura. 
You assume any and all reponsibility for this, I make no warranties 
or guarantees. Make sure that you have prepared a backup and know 
how to restore it, and are prepared to reset the device to factory 
settings or to use the recovery procedure if things should go wrong. 

### Getting started

This project makes use of a microSD card to hold the chrooted environment.
You must prepare this card by creating at least one partition 
that is marked as a Linux partition (ie. partition type 83 or 0083) and
is formatted as ext2, ext3 or ext4. This filesystem should be empty, or at 
least not contain a file or directory named `rootfs`.

You can install the chroot as follows:

- Make sure that the WiFi connection on your Kobo Aura is configured and working

- Turn off your Kobo Aura and insert the prepared microSD card into the slot 
at the bottom.

- Connect your Kobo Aura to your computer, wait for the Kobo to turn on and confirm
to connect it as a USB disk device.

- Download the latest `KoboRoot.tgz` release for this project from the release page at 
https://github.com/kintsugi-computer/kobo_bootstrap/releases. Place the `KoboRoot.tgz` 
file in the `.kobo` subdirectory on the `KOBOeReader` disk.

- Safely eject the Kobo ereader disk and wait for the update to complete. The Kobo Aura 
will install the files from the `KoboRoot.tgz` archive and then it will reboot.

- Enable WiFi by hand if that is not enabled automatically after the Kobo reboots. 
The installer will wait a maximum of 30 seconds for a network connection to 
become active, otherwise it will terminate without completing the installation.

- Allow 60 seconds from the moment the network has become active for the installation
to complete. The installer will download the chroot scripts and the minimal rootfs 
to create and enable the chrooted environment. It will then install and activate the 
Dropbear SSH server.

You can access the chrooted environment by enabling the Wifi connection and then using 
SSH. Get the IP address of the Kobo Aura by selecting `Settings` from the `Menu` and then
opening `Device Information`. Use the account name `root` and the password
`koboroot` to authenticate. You can change the password using the `password` 
command when you log in and you can create an `~/.ssh/authorized_keys` file for
the root account.

The Alpine Linux chroot environment is very minimal, based on the minimal rootfs
with dropbear and openssh-sftp-server packages as the only additions. You can 
use the `apk add` command to install additional packages. Keep in mind
however, that it is possible that the current packages may expect kernel features
that are not available in the stock 2.6.35 kernel or that were not compiled into it.

The original root filesystem with the Kobo Aura firmware is mounted under
`/mnt/koboroot` within the Alpine chroot. You can run commands on the
original firmware by chrooting into this directory, using 
`chroot /mnt/koboroot <command>`.

The installation creates a logfile in `.bootstrap/bootstrap.log` on the 
`KOBOeReader` disk. You can check this if things seems to go wrong.

## Background

### How it works

The KoboRoot.tgz archive installs a few scripts in `/usr/local/bootstrap` 
that are triggered at boot by a udev rules file. This method was copied
from work by Niluje and others (see https://www.mobileread.com/forums/showthread.php?t=254214).
The advantage of this approach is that it is not overwritten by firmware
updates.

The first script that is invoked, `bootstrap-init.sh`, invokes the 
second script `bootstrap.sh` in the background and in a shell that is 
detached from the `udev` process group to allow it to run without being 
killed when `udev` completes. This gives it the time to perform longer-running tasks.

The `bootstrap.sh` script then calls the numbered scripts in the
`/usr/local/bootstrap` directory that do the actual work. The first
script `20-mount-chroot.sh` does the following:

- identifies the Linux partition on the external microSD card and mounts
this at `/mnt/chroot`

- enable WiFi if there is no active network in order to be able to download the required
files from the Internet. WiFi is disabled after the downloads have finished.

- downloads the Alpine armhf minirootfs and unpacks it in `/mnt/chroot/rootfs`.

- downloads and unpacks an archive with scripts from https://github.com/kintsugi-computer/kobo_chroot_scripts.
This is unpacked in `/mnt/chroot` and provides the scripts to prepare the chroot 
environment by mounting the virtual and physical filesystems and to execute 
tasks within the chroot.

The second script `30-dropbear.sh`, does the following:

- install the `dropbear` and `openssh-sftp-server` Alpine packages and set the initial password 
for the root account in the chroot to `koboroot`, if these packages have not already been installed. 

- start the the dropbear service in the chroot

If you are already using another SSH service, then you can remove the script
`./usr/local/bootstrap/30-dropbear.sh` from the `KoboRoot.tgz` archive by unpacking
it, removing the file and rebuilding the `KoboRoot.tgz` file. You can also
remove the execute bit from the file. The bootstrap script will then skip it.

Alternatively you can disable you current SSH server and switch to the chrooted
dropbear.

The chroot is created on a Linux partition on the external microSD card because space
on the internal FAT-formatted storage is limited and the chrooted environment requires
a Linux filesystem such as ext2, etx3 or ext4. However, this approach can only work
for models that have an SD card slot. For other models one could use a loopback-device on FAT
partition (see https://www.mobileread.com/forums/showthread.php?t=336175) to create
a suitable filesystem for the chroot.

### Why Alpine Linux?

The main challenge in finding a suitable distribution for the chroot on 
the Kobo Aura is that the stock firmware uses a version 2.6.35 kernel which is
quite old by now. Current releases of the major distributions such as Debian 
and its derivatives are compiled for glibc versions that require later kernels. 
Only the wheezy and jessie versions of Debian could theoretically be used on 
the Kobo Aura, but both of these versions have been archived and are not available 
when using the standard installation procedure.  You might get quite far by 
manually changing the repository URL in the debootstrap script to create a 
minimal rootfs from the archived files, but then you're still 
limited to old versions of the available packages.

Alpine Linux is specifically aimed at minimal and embedded environments and
provides a current distribution that appears to be largely compatible with 
the 2.6.35 kernel. Alpine Linux makes use of the Musl C library, as opposed to the glibc 
library, which offers a good level of compatibility with older kernels: full POSIX 
compliance is guaranteed for kernels from version 2.6.39 onwards and older kernels
will work with some level of non-conformance. The stock kernel in the Kobo Aura is 
just a bit older at version 2.6.35, and seems to work fine.

### Why?

I have no practical reasons for doing this. I happened to stumble upon a Kobo Aura
at a thrift shop and couldn't resist when I looked it up and found a thriving 
hacking community. My goal was mostly to see if I could get some self-made interactive 
program to run on it. I prefer Python but did not like the prospect of cross-compiling
PyQT4 with its SIP-based build system for the Kobo Aura. So I considered compiling locally, 
which led me to the chroot solution by NiMa. And then I decided to try running a chroot 
with X11 and using tkinter in Python3. I wanted to automate the creation of the chroot 
starting from an updated but fully stock Kobo Aura firmware, which resulted in this project.

## Remarks

My sincerest thanks and appreciation to the people of the Kobo Developer's Corner at
www.mobileread.com, specifically to NiLuJe (https://www.mobileread.com/forums/showthread.php?t=254214) and 
NiMa (https://www.mobileread.com/forums/showthread.php?t=336175).

Installing this project on other Kobo models than the Kobo Aura N514 has not been tested and 
will require changes if there is no slot for an external SD card. In that case a a loopback 
filesystem on the `/mnt/onboard` partition will be required to hold the chroot (or maybe it is
possible to shrink the onboard FAT partition and create a new Linux partition for the chroot?).
