FROM debian:bookworm-20240513-slim@sha256:804194b909ef23fb995d9412c9378fb3505fe2427b70f3cc425339e48a828fca

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH
ARG BUILD_VERSION=local

# renovate: datasource=github-tags depName=yfhme/y-cs-firewall-bouncer
ENV FW_BOUNCER_VERSION=v0.0.29-rc2
ENV BOUNCER_URL=https://github.com/yfhme/y-cs-firewall-bouncer/releases/download/$FW_BOUNCER_VERSION/crowdsec-firewall-bouncer-linux-$TARGETARCH.tgz 

COPY crowdsec-firewall-bouncer-linux-$TARGETARCH.tgz /tmp/src/

WORKDIR /tmp/src

RUN set -x && \
  ls -al && \
  ls -al /tmp/src && \
  echo $BUILD_VERSION && \
  apt-get update && \
  apt-get purge -y --auto-remove nftables && \
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
  gettext \
  ipset \
  iptables && \
  tar xzvf crowdsec-firewall-bouncer-linux-$TARGETARCH.tgz && \
  rm -f crowdsec-firewall-bouncer-linux-$TARGETARCH.tgz && \
  cd crowdsec-firewall-* && \
  ./install-docker.sh && \
  apt-get purge -y --auto-remove && \
  rm -rf \
  /usr/local/go \
  /tmp/* \
  /var/tmp/* \
  /var/lib/apt/lists/*

ENTRYPOINT crowdsec-firewall-bouncer -c /crowdsec-firewall-bouncer.yaml
