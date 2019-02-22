# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

consul:
  register:
    - name: nginx
      port: 80
      tags:
        - group1
        - test
        - nginx
    - name: group2-production
      port: 81
      tags:
        - group2
        - production
        - nginx
