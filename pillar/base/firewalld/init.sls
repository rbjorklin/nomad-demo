# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:
firewalld:
  enabled: True
  default_zone: public
  services:
    consul:
      short: consul
      description: "consul"
      ports:
        tcp:
          - 8300
          - 8301
          - 8302
        udp:
          - 8301
          - 8302
    nomad:
      short: nomad
      description: "nomad"
      ports:
        tcp:
          - 4646
          - 4647
          - 4648
        udp:
          - 4648
    vault:
      short: vault
      description: "vault"
      ports:
        tcp:
          - 8200
          - 8201
    salt:
      short: salt
      description: "salt"
      ports:
        tcp:
          - 4505
          - 4506

