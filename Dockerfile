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
RUN wget http://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubectl && \
    chmod 555 kubectl && \
    mv kubectl /usr/local/bin/kubectl

COPY crontab /etc/cron.d/backup
COPY *.sh /usr/local/bin/

WORKDIR /root

CMD ["entrypoint.sh"]
