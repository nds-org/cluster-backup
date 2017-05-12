#!/bin/bash
[ $DEBUG ] && set -x

# XXX: Set this to "echo" to for a dry-run
DEBUG=""

# Grab date / cluster name
DATE=$(date +%y-%m-%d.%H%M)
IFS='-' read -ra HOST <<< "${HOSTNAME:-localhost}"
TARGET_PATH=${BACKUP_DEST:-/ndsbackup}/${HOST[0]}

echo "Listing known backups for ${HOST[0]}:"

# Use the above to build our base commands
SSH_ARGS="-i ${BACKUP_KEY:-backup.pem} -o StrictHostKeyChecking=no "
SSH_TARGET="${BACKUP_USER:-centos}@${BACKUP_HOST:-localhost}"

# Check contents of remote backup directory
$DEBUG ssh ${SSH_ARGS} ${SSH_TARGET} "ls -l ${TARGET_PATH}" | awk '{print $9}' | grep -v -e '^$'


