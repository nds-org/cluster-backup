FROM debian:jessie

#
# Install wget/ssh/cron/vim/pip via apt, and etcdumper via pip
# 
RUN apt-get -qq update && \
    apt-get -qq install --no-install-recommends \
        wget \
        vim \
        cron \
        openssh-client \
        python-pip && \
    pip install etcddump && \
    apt-get -qq autoremove && \
    apt-get -qq autoclean && \
    apt-get -qq clean all && \
    rm -rf /var/cache/apk/* /go

#
# Download kubectl binary
#
ARG K8S_VERSION="1.5.2"
RUN wget --no-verbose http://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl && \
    chmod 555 /usr/local/bin/kubectl

# Move scripts to WORKDIR
WORKDIR /root
COPY *.sh ./
COPY crontab /etc/cron.d/backup
COPY Dockerfile entrypoint.sh /

CMD ["/entrypoint.sh"]
