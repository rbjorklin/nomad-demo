# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

nomad:
  config:
    server:
      enabled: True
      bootstrap_expect: 3
      encrypt: "AaABbB+CcCdDdEeeFFfggG=="
      server_join:
        retry_join:
        {% for _, addrs in salt.saltutil.runner('mine.get', tgt='nomad:config:server:enabled:True', fun='network.ip_addrs', tgt_type='pillar') | dictsort() %}
          - {{ addrs[0] }}
        {% endfor %}
