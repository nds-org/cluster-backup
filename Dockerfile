FROM debian:jessie

#
# Add the tools
# 
RUN 	 \
    apt-get -y update && apt-get -y install \
    wget \
	bash vim-tiny \
    cron \
	openssh-client && \
    apt-get -y autoremove &&\
    apt-get -y autoclean &&\
    apt-get -y clean all &&\
    rm -rf /var/cache/apk/* 

#
# kubectl
#
ADD http://storage.googleapis.com/kubernetes-release/release/v1.3.5/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod 555 /usr/local/bin/kubectl

#
# etcdctl
#
RUN ( cd /usr/local && wget https://github.com/coreos/etcd/releases/download/v3.0.10/etcd-v3.0.10-linux-amd64.tar.gz &&\
tar -Oxf etcd-v3.0.10-linux-amd64.tar.gz etcd-v3.0.10-linux-amd64/etcdctl > /usr/local/bin/etcdctl && chmod u+x /usr/local/bin/etcdctl && rm etcd-v3.0.10-linux-amd64.tar.gz ) 

COPY FILES.deploy-tools /
WORKDIR /root

