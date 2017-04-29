#!/bin/bash
LOG=/dev/cron.log
touch ${LOG}
ln -s ${LOG} /var/log/cron.log
cron

echo 'Automated cluster backups now running:'
echo "BACKUP_SRC:    ${BACKUP_SRC}"
echo "BACKUP_HOST:   ${BACKUP_HOST}"
echo "BACKUP_KEY:    ${BACKUP_KEY}"
echo "BACKUP_USER:   ${BACKUP_USER}"
echo "BACKUP_DEST:   ${BACKUP_DEST}"

tail -f ${LOG}


