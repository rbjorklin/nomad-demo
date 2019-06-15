# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

nomad:
  config:
    server:
      enabled: True
      bootstrap_expect: 3
      encrypt: "AaABbB+CcCdDdEeeFFfggG=="
      server_join:
        retry_join:
          - 116.203.116.179
          - 116.203.116.200
          - 116.203.116.188
