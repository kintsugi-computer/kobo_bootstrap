#!/bin/sh
for script in /usr/local/bootstrap/scripts/??-*.sh
do
    if [ -x "${script}" ];
    then
        /bin/sh "${script}"
    fi
done
