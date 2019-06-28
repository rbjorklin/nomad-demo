# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

bind:
  config:
    options:
      allow-recursion: '{ localnets; localhost; }'
      allow-query-cache: '{ localnets; localhost; }'
      listen-on: 'port 53 { 0.0.0.0; }'
      listen-on-v6: 'port 53 { ::1; }'
      allow-query: '{ any }'
      recursion: 'yes'
      dnssec-enable: 'no'
      dnssec-validation: 'no'
  configured_zones:
    consul:
      type: forward
      forward: only
      forwarders:
        - 127.0.0.1 port 8600
    rbjorklin.com:
      type: master
      notify: False
  available_zones:
    rbjorklin.com:
      file: rbjorklin.com.txt
      soa:
        ns: salt.rbjorklin.com
        contact: rbjorklin@example.com
        serial: auto
      records: # Records for the zone, grouped by type
        A:
          {% for node, addrs in salt.saltutil.runner('mine.get', tgt='*', fun='network.ip_addrs') | dictsort() %}
          {{ node.split('.')[0] }}: {{ addrs[0] }}
          {% endfor %}
        NS:
          '@':
            - node01
        CNAME:
          haproxy: haproxy.service.consul.
          consul-ui: haproxy.service.consul.
          nomad: haproxy.service.consul.
          jenkins: haproxy.service.consul.
          gitea: haproxy.service.consul.
