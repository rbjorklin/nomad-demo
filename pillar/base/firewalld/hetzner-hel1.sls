# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:
firewalld:
  zones:
    hetzner:
      short: Hetzner
      description: "Hetzner Cloud"
      services:
        - consul
        - nomad
        - vault
        - salt
      sources:
        # https://ipinfo.io/AS24940#ipv4-data
        - source: 95.216.0.0/16
          comment: Hetzner Online GmbH (hel1)
        - source: 95.217.0.0/16
          comment: Hetzner Online GmbH (hel1)