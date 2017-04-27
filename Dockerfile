FROM debian:jessie


#
# kubectl
#
ADD http://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod 555 /usr/local/bin/kubectl

#
# Add the tools
# 
RUN 	 \
    apt-get -y update  \
    && apt-get -y install --no-install-recommends \
        wget \
        bash vim-tiny \
        cron \
        openssh-client \
        xfsdump \
        python-pip \
    && pip install etcddump \
    && apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean all \
    && rm -rf /var/cache/apk/* /go

COPY FILES.cluster-backup /
WORKDIR /root
RUN chmod 755 /usr/local/bin/* /etc/cron.d/*
CMD ["entrypoint"]
