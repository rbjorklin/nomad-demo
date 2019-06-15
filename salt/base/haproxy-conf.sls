# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

ensure haproxy bootstrap config exists:
  file.managed:
    - name: /opt/haproxy/conf/frontend.cfg
    - source: salt://haproxy/bootstrap.cfg.j2
    - template: jinja
    - makedirs: True
