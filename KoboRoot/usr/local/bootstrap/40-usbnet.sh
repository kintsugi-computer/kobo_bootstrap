#!/bin/sh

function enable_usbnet {
  module_path="/drivers/mx50-ntx/usb/gadget"
  intf="usb0"
  intf_state="/sys/class/net/${intf}/operstate"
  ipaddr="192.168.2.2"
  gateway="192.168.2.1"

  # Use the serial number for the macaddresses, using the 'A' and 'E'
  # ranges that are reserved as locally administered ranges
  sn="$(dd if=/dev/mmcblk0 skip=$((0x00000200)) count=64 bs=1)"
  hostaddr="${sn:6:1}A:${sn:7:2}:${sn:9:2}:${sn:11:2}:${sn:13:2}:${sn:15:2}"
  devaddr="${sn:6:1}E:${sn:7:2}:${sn:9:2}:${sn:11:2}:${sn:13:2}:${sn:15:2}"

  /sbin/insmod "${module_path}/arcotg_udc.ko"
  /sbin/insmod "${module_path}/g_ether.ko" host_addr="${hostaddr}" dev_addr="${devaddr}"

  if [ ! -e "${intf_state}" -o "$( cat "${intf_state}")" != "up" ]; then
    /sbin/ifconfig "${intf}" "${ipaddr}"
    /sbin/ip route add default via "${gateway}" dev "${intf}" metric 500
  fi
}

function disable_usbnet {
  if [ -e "${intf_state}" -a "$( cat "${intf_state}")" == "up" ]; then
    /sbin/ip route del default via "${gateway}"
    /sbin/ifconfig "${intf}" down
  fi
  /sbin/rmmod g_ether
  /sbin/rmmod arcotg_udc.ko
}

if [ "${1}" == "shutdown" ]; then
  disable_usbnet
  exit
fi

enable_usbnet

