#!/bin/sh

# Spawn the actual bootstrap script as a daemon

THISSCRIPT="/usr/local/bootstrap/bootstrap-init.sh"

case "x-${1}" in 
    x-stage_one)
        # Second entry point: set working dir to / and rebind stdin, stdout, stderr
        cd /
        "${THISSCRIPT}" stage_two "$@" </dev/null >/dev/null 2>/dev/null &
        exit 0
        ;;
    x-stage_two)
        # Third entry point. We are a deamon now, in our own process
        # group, with / as working directory and detached from the
        # original stdin, stdout and stderr
        
        # start the actual work
        /usr/local/bootstrap/bootstrap.sh
        ;;
    *)  
        # First entry point: detach from the process group
        setsid "${THISSCRIPT}" stage_one "$@" &
        exit 0
        ;;
esac
