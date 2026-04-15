function logmsg {
  echo "$(date "+%Y-%m-%d %H:%M:%S") ${1}"
}

function start_network {
  waittime=30
  while [ "${waittime}" -gt 0 -a ! -e /sys/devices/virtual/net/????* ]; do
    
    logmsg "-- No active network: waiting: $((--waittime))"
    sleep 1
  done
  if [ -e /sys/devices/virtual/net/????* ]; then
    logmsg "-- Active network found"
    return 0
  fi
  logmsg "-- No active network"
  return 1
}

function stop_process {
  process_name="${1}"
  for count in 1 2 3 ; do
    if pidof "${process_name}"; then
      /usr/bin/killall "${process_name}"
    else
      break
    fi
    if ! pidof "${process_name}"; then
      break
    fi
    /bin/usleep 200
  done
  if pidof "${process_name}"; then
    logmsg "-- failed terminating ${process_name}"
  else
    logmsg "-- terminated ${process_name}"
  fi

}
