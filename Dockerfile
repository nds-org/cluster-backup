FROM debian:jessie

#
# Add the tools
# 
RUN 	 \
    apt-get -y update  \
    && apt-get -y install \
        wget \
        bash vim-tiny \
        cron \
        openssh-client \
        xfsdump \
        golang \
        git \
    && mkdir -p /go/src /go/bin \
    && export GOPATH=/go \
    && go get github.com/coreos/go-etcd/etcd \
    && cd /go/src \
    && git clone https://github.com/fanhattan/etcd-backup.git \
    && cd etcd-backup \
    && go install \
    && cp *.json /etc \
    && install /go/bin/etcd-backup /usr/local/bin \
    && apt-get -y remove golang git \
    && apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean all \
    && rm -rf /var/cache/apk/* /go

#
# kubectl
#
ADD http://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod 555 /usr/local/bin/kubectl

COPY FILES.cluster-backup /
WORKDIR /root
RUN chmod 755 /usr/local/bin/* /etc/cron.d/*
CMD /usr/local/bin/entrypoint
