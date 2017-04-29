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
SSH_TARGET="${BACKUP_USER:-centos}@${BACKUP_HOST:-localhost}/${DATE}"

# Ensure data dir exists remotely
$DEBUG ssh ${SSH_ARGS} ${SSH_TARGET} "mkdir -p ${TARGET_PATH}"

# Dump shared BACKUP_SRC state
$DEBUG tar czf - ${BACKUP_SRC} | $DEBUG ssh ${SSH_ARGS} ${SSH_TARGET} "cat - > ${TARGET_PATH}/${DATE}.glfs-state.tgz"

# Dump etcd state
$DEBUG /usr/local/bin/etcdumper dump http://${ETCD_HOST:-localhost}:${ETCD_PORT:-2379} --file /tmp/${DATE}-etcd-backup.json
$DEBUG scp ${SSH_ARGS} /tmp/${DATE}-etcd-backup.json ${SSH_TARGET}:${TARGET_PATH}/${DATE}-etcd-backup.json

# Dump Kubernetes cluster state
# TODO: Verify kubeconfig is correct / present
# FIXME: kubectl cluster-info dump is currently incomplete, as it relies on the broken kubectl logs
# FIXME: See https://github.com/kubernetes/kubernetes/issues/38774
$DEBUG /usr/local/bin/kubectl cluster-info dump | $DEBUG ssh ${SSH_ARGS} ${SSH_TARGET}  sudo "cat - >  ${TARGET_PATH}/${DATE}-kubectl.dump"

echo "Backup complete: ${DATE}"

# TODO: Delete local backups after successful transfer?
