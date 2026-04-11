#!/bin/sh
MOUNTPOINT="/mnt/onboard/"
BOOTSTRAP_LOGDIR="${MOUNTPOINT}.bootstrap"
BOOTSTRAP_LOG="/dev/null"

# Wait until /mnt/onboard has become available
for i in 1 2 3 4; do
    if mountpoint "${MOUNTPOINT}"; then
        break
    fi
    sleep 1
done

if mountpoint "${MOUNTPOINT}"; then
    mkdir -p "${BOOTSTRAP_LOGDIR}"
    BOOTSTRAP_LOG="${BOOTSTRAP_LOGDIR}/bootstrap.log"
    > "${BOOTSTRAP_LOG}"
fi

for script in /usr/local/bootstrap/??-*.sh
do
    if [ -x "${script}" ];
    then
        /bin/sh "${script}" >> "${BOOTSTRAP_LOG}"
    fi
done
