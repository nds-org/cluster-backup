core@lambert8-dev ~/cluster-backup $ cat list-backups.sh 
#!/bin/bash
[ $DEBUG ] && set -x

# XXX: Set this to "echo" to for a dry-run
DEBUG=""

# Set some basic
MYADDR=$(ip addr show eth0 scope global | grep inet | tr -s ' ' | cut -d' ' -f3 | cut -d/ -f1)
DATE=$(date +%y-%m-%d.%H%M)
TARGET_PATH=${BACKUP_DEST:-/ndsbackup}/${HOSTNAME:-localhost}

echo "Backup started: ${DATE}"

# Use the above to build our base commands
SSH_ARGS="-i ${BACKUP_KEY:-backup.pem} -o StrictHostKeyChecking=no "
SSH_TARGET="${BACKUP_USER:-centos}@${BACKUP_HOST:-localhost}"

# Check contents of remote backup directory
$DEBUG ssh ${SSH_ARGS} ${SSH_TARGET} "ls -al ${TARGET_PATH}"



