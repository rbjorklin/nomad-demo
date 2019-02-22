# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

consul_template:
  # Start consul-template daemon and enable it at boot time
  service: True

  config:
    consul: 127.0.0.1:8500
    log_level: info

  tmpl:
    - name: haproxy_backend.cfg
      source: salt://haproxy_backend.cfg.ctmpl
      config:
        template:
          source: /etc/consul-template/tmpl-source/haproxy_backend.cfg.ctmpl
          destination: /opt/haproxy/conf/backend.cfg
          command: systemctl reload haproxy
