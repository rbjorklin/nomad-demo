# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

consul:
  config:
    ui: True
    #client_addr: 0.0.0.0
  register:
    - name: consul-ui
      address: 127.0.0.1
      port: 8500
      tags:
        - saltstack
        - haproxy
        - http
