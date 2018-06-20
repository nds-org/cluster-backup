# Workbench Cluster Backup
Automated nightly backup for etcd, shared filesystem, and cluster info dump for Workbench on Kubernetes

# Prerequisites
To build:
* Docker

To run:
* A remote machine's credentials: username / ssh key / hostname
* Kubernetes

# Build
The usual `docker build` command:
```bash
docker build -t ndslabs/cluster-backup:latest .
```

# Automated Backups
This container comes with cron installed, and a crontab file that will run backup.sh nightly.

There are two ways to run this container:
* Kubernetes (supported / recommended)
* Docker (unsupported, but theortically possible)

## Via Kubernetes
Create a Kubernetes secret named `backup-key` from the SSH key used to access the recipient of the backups:
```bash
kubectl create secret generic backup-key --from-file=ssh-privatekey=/path/to/backup.pem
```

Then modify `cluster-backup.yaml` to adjust `BACKUP_HOST` and `BACKUP_USER` to your liking and run:
```bash
kubectl create -f cluster-backup.yaml
```

## Via Docker
You will need to provide quite a few parameters to use this image without Kubernetes:
* `-v /path/to/your.pem:/root/.ssh/backup.pem`: Mount the .ssh key to access the backup machine into the container
* `-v /var/glfs:/var/glfs`: Mount the GlusterFS filesystem from the host into the container
* `-e ETCD_HOST`: The hostname of the etcd instance to back up
* `-e ETCD_PORT`: The port of the etcd instance to back up
* `-e HOSTNAME`: A short identifier for your cluster
* `-e BACKUP_HOST`: The hostname of the remote machine which will accept backups
* `-e BACKUP_USER`: The username to use to connect to the remote backup machine
* `-e BACKUP_KEY`: The path to the .pem file that we mounted above with `-v`
* `-e BACKUP_SRC`: The source path of the directory we wish to back up
* `-e BACKUP_DEST`: The destination path on the remote machine where we wish to store backups

NOTE: the kubectl dump portion of the backup will obviously fail, since your are not running under Kubernetes in this instance.

```bash
docker run -d -it -v /path/to/your.pem:/root/.ssh/backup.pem -v /var/glfs:/var/glfs -e BACKUP_USER=centos -e BACKUP_HOST=xxx.xxx.xxx.xxx -e BACKUP_KEY=/root/.ssh/backup.pem -e BACKUP_SRC=/var/glfs -e BACKUP_DEST=/ndsbackup -e ETCD_HOST=xxx.xxx.xxx.xxx -e ETCD_PORT=4001 -e HOSTNAME=cluster-name ndslabs/cluster-backup:latest bash
```

# List the Available Backups
```bash
./list-backups.sh  
````

This will list all of the backups that exist on the remote machine for the given HOSTNAME:
```bash
Listing known backups for nds752:
17-04-29.2228
```

# Retrieve a Backup
```bash
./retrieve-backup.sh 17-04-29.2228  
```

This will download the set of three "backup" files:
* `etcd-backup.json`: A backup of the Workbench etcd data - service catalog, users, and their added applications
* `glfs-state.tgz`: A backup of the shared cluster filesystem - the glusterfs volumes backing the users' application
* `kubectl.dump`: A verbose set of YAMLs / available log pod output from the Kubernetes API server useful for debugging (broken in Kubernetes 1.5.1)

```bash
Retrieving backup 17-04-29.2228 for nds752: 
17-04-29.2228-etcd-backup.json
17-04-29.2228.glfs-state.tgz
17-04-29.2228-kubectl.dump
```

# Restore GLFS from Backup
Untar the glfs dump:
```bash
sudo tar zxvf ./17-04-29.2228.glfs-state.tgz -C /tmp
```

I recommend copying any inconsistent data from `/tmp` by hand.

WARNING: `C /` will extract over the existing glfs data

# Restore ETCD from backup
```bash
etcd-load restore --etc=${ETCD_HOST}:${ETCD_PORT} 17-04-29.2228/17-04-29.2228-etcd-backup.json
```

# Gotchas
* cron hates environment variables
* although the scripts will retrieve a set of backup files, the "restore" process is completely manual to avoid mishaps
