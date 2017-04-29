# Labs Workbench Cluster Backup
Automated nightly backup for etcd, shared filesystem, and cluster info dump for Labs Workbench on Kubernetes

# Prerequisites
To build:
* Docker

To run:
* A remote machine's credentials: username / ssh key / 
* Docker / Kubernetes
* 

# Build
The usual `docker build` command:
```bash
docker build -t ndslabs/cluster-backup:latest .
```

# Via Kubernetes
Create a Kubernetes secret named `backup-key` from the SSH key used to access the recipient of the backups:
```bash
kubectl create secret generic backup-key --from-file=ssh-privatekey=/path/to/backup.pem
```

Then modify `cluster-backup.yaml` to your liking and run:
```bash
kubectl create -f cluster-backup.yaml
```

# Via Docker
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

```bash
docker run -d -it -v /path/to/your.pem:/root/.ssh/backup.pem -v /var/glfs:/var/glfs -e BACKUP_USER=centos -e BACKUP_HOST=xxx.xxx.xxx.xxx -e BACKUP_KEY=/root/.ssh/backup.pem -e BACKUP_PATH=/ndsbackup -e BACKUP_SRC=/var/glfs -e BACKUP_DEST=/ndsbackup -e ETCD_HOST=xxx.xxx.xxx.xxx -e ETCD_PORT=4001 -e HOSTNAME=cluster-name ndslabs/cluster-backup:latest bash
```

# Gotchas
* cron hates environment variables
* "restore" process is completely manual, to avoid mishaps
