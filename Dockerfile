FROM debian:bookworm-20240904-slim@sha256:a629e796d77a7b2ff82186ed15d01a493801c020eed5ce6adaa2704356f15a1c

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH
ARG BUILD_VERSION=local

# renovate: datasource=github-tags depName=yfhme/y-cs-firewall-bouncer
ENV FW_BOUNCER_VERSION=v0.0.30
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

ENTRYPOINT ["crowdsec-firewall-bouncer", "-c", "/crowdsec-firewall-bouncer.yaml"]
