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
