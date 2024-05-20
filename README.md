<p align="center">
<img src="https://github.com/crowdsecurity/cs-firewall-bouncer/raw/main/docs/assets/crowdsec_linux_logo.png" alt="CrowdSec" title="CrowdSec" width="300" height="280" />
</p>
<p align="center">
<img src="https://img.shields.io/badge/build-pass-green">
<img src="https://img.shields.io/badge/tests-pass-green">
</p>
<p align="center">
&#x1F4DA; <a href="#installation">Documentation</a>
&#x1F4A0; <a href="https://hub.crowdsec.net">Hub</a>
&#128172; <a href="https://discourse.crowdsec.net">Discourse </a>
</p>


# crowdsec-firewall-bouncer
Crowdsec bouncer written in golang for firewalls.

crowdsec-firewall-bouncer will fetch new and old decisions from a CrowdSec API to add them in a blocklist used by supported firewalls.

Supported firewalls:
 - iptables (IPv4 :heavy_check_mark: / IPv6 :heavy_check_mark: )
 - nftables (IPv4 :heavy_check_mark: / IPv6 :heavy_check_mark: )
 - ipset only (IPv4 :heavy_check_mark: / IPv6 :heavy_check_mark: )
 - pf (IPV4 :heavy_check_mark: / IPV6 :heavy_check_mark: )

Find the [official documentation](https://doc.crowdsec.net/docs/bouncers/firewall) here for non-bouncer version.

# Installation

> [!WARNING]
> This is an experimental docker image for the crowdsec firewall bouncer. Use at your own risk.

## Notes
- This version uses iptables, so you must have those on your host system
- Recommend using the `latest` tag or a version number tag e.g. `v0.0.29-rc2`
- A configuration file must be mounted to `/crowdsec-firewall-bouncer.yaml` as this image does not contain a 'default'

## Getting Started

Below is an example docker-compose.
```
services:
  cs-firewall-bouncer:
    image: yfhme/cs-firewall-bouncer-docker:latest
    container_name: cs-firewall-bouncer
    restart: unless-stopped
    depends_on:
      crowdsec:
        condition: service_healthy # ensure crowdsec service up to avoid errors
    environment:
      - TZ='America/New_York'
    cap_add:
      # allow modification of host's iptable
      - NET_ADMIN
      - NET_RAW
    network_mode: "host"
    volumes:
      - ./crowdsec-firewall-bouncer.yaml:/crowdsec-firewall-bouncer.yaml # see below for example config file
```

The below is an example `crowdsec-firewall-bouncer.yaml` file that needs to be mounted into the container at `/crowdsec-firewall-bouncer.yaml`

See https://docs.crowdsec.net/u/bouncers/firewall/ for more information about the config. Currently only iptables is supported.

```
# crowdsec-firewall-bouncer.yaml
mode: iptables
pid_dir: /var/run/
update_frequency: 60s
daemonize: true
log_mode: stdout # file or stdout
log_dir: /var/log/
log_level: info # trace, debug, info, or error
log_compression: true
log_max_size: 100
log_max_backups: 3
log_max_age: 30
api_url: http://127.0.0.1:8080/
api_key: 88ACC7CD82C4F268722803B2C2A # as created in crowdsec
insecure_skip_verify: false
disable_ipv6: false
deny_action: DROP
deny_log: false
supported_decisions_types:
  - ban
# to change log prefix
# deny_log_prefix: "crowdsec: "
# to change the blacklists name
blacklists_ipv4: crowdsec-blacklists
ipset_size: 131072
blacklists_ipv6: crowdsec6-blacklists
# if present, insert rule in those chains
iptables_chains:
  - INPUT
  #  - FORWARD
  - DOCKER-USER

prometheus:
  enabled: false
  listen_addr: 127.0.0.1
  listen_port: 60601
```

### Config file options

| Option  | Description |
| ------------- | ------------- |
| `api_url`  | This should point to your crowdsec instance. Because we use `network_mode: host` this is set to `127.0.0.1:8080` where 8080 is the port that crowdsec itself is listening  |
| `api_key`  | The API key created either in crowdsec with `cscli bouncer add firewallbouncer` or by adding a ENV variable to crowdsec compose `BOUNCER_KEY_firewall=mysecrectkey12345` (see the **Automatic Bouncer Registration** section of the [crowdsec docs](https://hub.docker.com/r/crowdsecurity/crowdsec)) |
