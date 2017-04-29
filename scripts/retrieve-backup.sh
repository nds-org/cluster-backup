#!/bin/bash
[ $DEBUG ] && set -x

# XXX: Set this to "echo" to for a dry-run
DEBUG=""

# Grab date / cluster name
IFS='-' read -ra HOST <<< "${HOSTNAME:-localhost}"
TARGET_PATH=${BACKUP_DEST:-/ndsbackup}/${HOST[0]}/$1

echo "Retrieving backup $1 for ${HOST[0]}: ${DATE}"

# Use the above to build our base commands
SSH_ARGS="-i ${BACKUP_KEY:-backup.pem} -o StrictHostKeyChecking=no "
SSH_TARGET="${BACKUP_USER:-centos}@${BACKUP_HOST:-localhost}"

# Retrieve contents of remote backup from the given string
$DEBUG scp -r ${SSH_ARGS} ${SSH_TARGET}:${TARGET_PATH} $(pwd)/$1 



