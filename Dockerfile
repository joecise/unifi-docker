FROM debian:stretch-slim

ARG DEBIAN_FRONTEND=noninteractive

ENV PKGURL=https://dl.ubnt.com/unifi/5.5.20/unifi_sysvinit_all.deb

RUN mkdir -p /usr/share/man/man1 /var/cache/apt/archives && \
  apt-get clean && \
  apt-get update && \
  apt-get install -y --no-install-recommends apt-utils && \
  apt-get install -y --no-install-recommends procps gnupg dirmngr curl gdebi-core && \
  apt-get install -y --no-install-recommends ca-certificates-java openjdk-8-jre-headless && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50 && \
  echo "deb http://www.ubnt.com/downloads/unifi/debian unifi-5.5 ubiquiti" | tee /etc/apt/sources.list.d/20ubiquiti.list && \
  apt-get update && \
  curl -o ./unifi.deb ${PKGURL} && \
  yes | gdebi ./unifi.deb && \
  rm -f ./unifi.deb && \
  apt-get purge -qy --auto-remove curl gdebi-core && \
  apt-get clean -qy && \
  rm -rf /var/lib/apt/lists/*

ENV BASEDIR=/usr/lib/unifi \
  DATADIR=/var/lib/unifi \
  RUNDIR=/var/run/unifi \
  LOGDIR=/var/log/unifi \
  JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
  JVM_MAX_HEAP_SIZE=1024M \
  JVM_INIT_HEAP_SIZE=

RUN ln -s ${BASEDIR}/data ${DATADIR} && \
  ln -s ${BASEDIR}/run ${RUNDIR} && \
  ln -s ${BASEDIR}/logs ${LOGDIR}

VOLUME ["${DATADIR}", "${RUNDIR}", "${LOGDIR}"]

EXPOSE 6789/tcp 8080/tcp 8443/tcp 8880/tcp 8843/tcp 3478/udp

COPY unifi.sh /usr/local/bin/
COPY import_cert.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/unifi.sh /usr/local/bin/import_cert.sh

WORKDIR /var/lib/unifi

CMD ["/usr/local/bin/unifi.sh"]
