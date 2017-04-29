#!/bin/bash
LOG=/dev/cron.log
touch ${LOG}
ln -s ${LOG} /var/log/cron.log
cron
tail -f ${LOG}


