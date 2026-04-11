MODULE_PATH=/drivers/mx50-ntx/wifi
WIFI_DRIVER_MODULE=dhd
WIFI_POWER_MODULE=sdio_wifi_pwr
ENABLED_WIFI=/bin/false

function logmsg {
    echo "$(date "+%F %T.%3N") ${1}"
}

function start_network {
    if [ ! -e /sys/devices/virtual/net/????* -a ! -e "/sys/module/${WIFI_DRIVER_MODULE}" ]; then
        /sbin/insmod "${MODULE_PATH}/${WIFI_POWER_MODULE}"
        /sbin/insmod "${MODULE_PATH}/${WIFI_DRIVER_MODULE}"
        sleep 1
        /sbin/ifconfig eth0 up
        /bin/wlarm_le -i eth0 up
        /bin/wpa_supplicant -s -i eth0 -c /etc/wpa_supplicant/wpa_supplicant.conf -C /var/run/wpa_supplicant -B
        /sbin/udhcpc -S -i eth0 -s /etc/udhcpc.d/default.script -t15 -T10 -A3 -f -q
        return "/bin/true"
    fi
    return "/bin/false"
}

function stop_network {
    if ${1}; then
        /usr/bin/killall udhcpc
        /usr/bin/killall wpa_supplicant
        /bin/wlarm_le -i eth0 down
        /sbin/ifconfig eth0 down
        /sbin/rmmod "${MODULE_PATH}/${WIFI_DRIVER_MODULE}"
        /sbin/rmmod "${MODULE_PATH}/${WIFI_POWER_MODULE}"
    fi
}
