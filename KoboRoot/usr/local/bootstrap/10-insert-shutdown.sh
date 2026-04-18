#!/bin/sh
if [ "${1}" == "shutdown" ]; then
  exit
fi

# Hook the shutdown scripts into /etc/init.d/rcK
if ! /bin/grep -q "/usr/local/bootstrap/shutdown.sh" /etc/init.d/rcK; then
  /bin/sed '/^umount -a -r/i /usr/local/bootstrap/shutdown.sh' /etc/init.d/rcK
fi
