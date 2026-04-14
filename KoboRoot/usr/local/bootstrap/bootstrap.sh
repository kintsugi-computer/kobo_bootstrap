#!/bin/sh
MOUNTPOINT="/mnt/onboard/"
BOOTSTRAP_LOGDIR="${MOUNTPOINT}.bootstrap"
BOOTSTRAP_LOG="/dev/null"

source /usr/local/bootstrap/bootstrap-functions.sh

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

logmsg "-- Starting bootstrap." >> "${BOOTSTRAP_LOG}"
for script in /usr/local/bootstrap/??-*.sh
do
    if [ -x "${script}" ];
    then
        logmsg ">> Calling ${script}" >> "${BOOTSTRAP_LOG}"
        /bin/sh "${script}" >> "${BOOTSTRAP_LOG}" 2>&1
        logmsg "<< Exiting ${script}" >> "${BOOTSTRAP_LOG}"
    fi
done
logmsg "-- bootstrap complete" >> "${BOOTSTRAP_LOG}"

