core@lambert8-dev ~/cluster-backup $ cat list-backups.sh 
#!/bin/bash
[ $DEBUG ] && set -x

# XXX: Set this to "echo" to for a dry-run
DEBUG=""

# Grab date / cluster name
DATE=$(date +%y-%m-%d.%H%M)
IFS='-' read -ra HOST <<< "${HOSTNAME:-localhost}"
TARGET_PATH=${BACKUP_DEST:-/ndsbackup}/${HOST[0]}

echo "Backup started: ${DATE}"

# Use the above to build our base commands
SSH_ARGS="-i ${BACKUP_KEY:-backup.pem} -o StrictHostKeyChecking=no "
SSH_TARGET="${BACKUP_USER:-centos}@${BACKUP_HOST:-localhost}"

# Retrieve contents of remote backup from the given string
$DEBUG ssh ${SSH_ARGS} ${SSH_TARGET} "ls -al ${TARGET_PATH}" | grep $1 | scp ${SSH_ARGS} ${SSH_TARGET}:- $HOME 



