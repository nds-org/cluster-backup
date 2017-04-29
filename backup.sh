#!/bin/bash
[ $DEBUG ] && set -x

DEBUG="echo"

# Set some basic 
MYADDR=$(ip addr show eth0 scope global | grep inet | tr -s ' ' | cut -d' ' -f3 | cut -d/ -f1)
DATE=$(date +%y-%m-%d-%H.%M)
BACKUP_PATH=${BACKUP_PATH:-/ndsbackup}/${HOSTNAME:-localhost}

# Use the above to build our base commands
SSH_ARGS="-i ${BACKUP_KEY} -o StrictHostKeyChecking=no "
SSH_TARGET="${BACKUP_USER:-centos}@${BACKUP_HOST:-localhost}"

# Ensure data dir exists remotely
$DEBUG ssh ${SSH_ARGS} ${SSH_TARGET} "mkdir -p ${BACKUP_PATH}"

# Dump shared filesystem state
GLFS_VOLUME_NAME=global
GLFS_DATA_DIR="/var/glfs/${GLFS_VOLUME_NAME:-global}"

# TODO: Do we really need to backup all of these? 
GLFS_ALL_DIRS="${GLFS_LIB_DIR:-/var/lib/glusterfs} ${GLFS_ETC_DIR:-/etc/glusterfs} ${GLFS_LOG_DIR:-/var/log/glusterfs} ${GLFS_DATA_DIR}"

# Backup only the DATA_DIR for now
$DEBUG tar czf - ${GLFS_DATA_DIR} | $DEBUG ssh ${SSH_ARGS} ${SSH_TARGET} "cat - > ${BACKUP_PATH}/${DATE}.glfs-state.tgz"

# Dump etcd state
$DEBUG /usr/local/bin/etcdumper dump http://${NDSLABS_ETCD_SERVICE_HOST:-localhost}:${NDSLABS_ETCD_SERVICE_PORT:-2379} --file /tmp/${DATE}-etcd-backup.json
$DEBUG scp ${SSH_ARGS} /tmp/${DATE}-etcd-backup.json ${SSH_TARGET}:${BACKUP_PATH}/${DATE}-etcd-backup.json

# Dump Kubernetes cluster state
# TODO: Verify kubeconfig is correct / present
$DEBUG /usr/local/bin/kubectl cluster-info dump | $DEBUG ssh ${SSH_ARGS} ${SSH_TARGET}  sudo "cat - >  ${BACKUP_PATH}/${DATE}-kubectl.dump"
