#!/bin/sh
MOUNTPOINT="/mnt/onboard"
BOOTSTRAP_LOGDIR="${MOUNTPOINT}/.bootstrap"
BOOTSTRAP_LOG="/dev/null"

source /usr/local/bootstrap/bootstrap-functions.sh

if mountpoint "${MOUNTPOINT}"; then
    mkdir -p "${BOOTSTRAP_LOGDIR}"
    SHUTDOWN_LOG="${BOOTSTRAP_LOGDIR}/shutdown.log"
    > "${SHUTDOWN_LOG}"
fi

logmsg "-- Starting shutdown." >> "${SHUTDOWN_LOG}"
for script in $(ls -r /usr/local/bootstrap/??-*.sh)
do
    if [ -x "${script}" ];
    then
        logmsg ">> Calling ${script}" shutdown >> "${SHUTDOWN_LOG}"
        /bin/sh "${script}" shutdown  >> "${SHUTDOWN_LOG}" 2>&1
        logmsg "<< Exiting ${script}" shutdown >> "${SHUTDOWN_LOG}"
    fi
done
logmsg "-- shutdown complete" >> "${SHUTDOWN_LOG}"

