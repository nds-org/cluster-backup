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
TARGET_PATH=${BACKUP_DEST:-/ndsbackup}/${CLUSTER_ID}/$1

echo "Retrieving backup $1 for ${CLUSTER_ID}: ${DATE}"

# Use the above to build our base commands
SSH_ARGS="-i ${BACKUP_KEY:-backup.pem} -o StrictHostKeyChecking=no "
SSH_TARGET="${BACKUP_USER:-centos}@${BACKUP_HOST:-localhost}"

# Retrieve contents of remote backup from the given string
$DEBUG scp -r ${SSH_ARGS} ${SSH_TARGET}:${TARGET_PATH} $(pwd)/$1 



