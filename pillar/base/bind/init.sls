# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

bind:
  config:
    options:
      allow-recursion: '{ any; }' # Never include this on a public resolver
      listen-on: 'port 53 { 10.10.10.10; }'
      listen-on-v6: 'port 53 { ::1; }'
      allow-query: '{ localhost; 10.10.10.0/24; }'
      recursion: 'yes'
      dnssec-enable: 'no'
      dnssec-validation: 'no'
  configured_zones:
    consul:
      type: forward
      forward: only
      forwarders:
        - 127.0.0.1 port 8600
    vagrant.rbjorklin.com:
      type: master
      notify: False
  available_zones:
    vagrant.rbjorklin.com:
      file: vagrant.rbjorklin.com.txt
      soa:
        ns: salt.vagrant.rbjorklin.com
        contact: rbjorklin@example.com
        #serial: {{ salt['cmd.run']('date +%s') }}
        serial: auto
      records:                                    # Records for the zone, grouped by type
        A:
          salt: 10.10.10.10
          node01: 10.10.10.11
          node02: 10.10.10.12
        NS:
          '@':
            - salt
        CNAME:
          haproxy: haproxy.service.consul.
          consul-ui: haproxy.service.consul.
          nomad: haproxy.service.consul.
          jenkins: haproxy.service.consul.
          gitea: haproxy.service.consul.
