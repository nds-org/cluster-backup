#!/bin/bash
[ $DEBUG ] && set -x

if [ "${CLUSTER_ID}" == "" ];
then
        echo "You must specify a CLUSTER_ID for the backup process"
        exit 1;
fi

# XXX: Set this to "echo" to for a dry-run
DEBUG=""

# Grab date / cluster name
DATE=$(date +%y-%m-%d.%H%M)
TARGET_PATH=${BACKUP_DEST:-/ndsbackup}/${CLUSTER_ID}

echo "Listing known backups for ${CLUSTER_ID}:"

# Use the above to build our base commands
SSH_ARGS="-i ${BACKUP_KEY:-backup.pem} -o StrictHostKeyChecking=no "
SSH_TARGET="${BACKUP_USER:-centos}@${BACKUP_HOST:-localhost}"

# Check contents of remote backup directory
$DEBUG ssh ${SSH_ARGS} ${SSH_TARGET} "ls -l ${TARGET_PATH}" | awk '{print $9}' | grep -v -e '^$'


