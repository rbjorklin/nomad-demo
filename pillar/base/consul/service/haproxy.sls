# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

consul:
  register:
    - name: haproxy
      port: 80
      tags:
        - saltstack
        - haproxy
        - http
