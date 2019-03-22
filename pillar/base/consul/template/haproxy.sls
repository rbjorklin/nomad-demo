# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

consul_template:
  tmpl:
    - name: haproxy_backend.cfg
      source: salt://haproxy/backend.cfg.ctmpl.j2
      config:
        template:
          source: /etc/consul-template/tmpl-source/haproxy_backend.cfg.ctmpl
          destination: /opt/haproxy/conf/backend.cfg
          command: systemctl reload haproxy
    - name: haproxy_frontend.cfg
      source: salt://haproxy/frontend.cfg.ctmpl.j2
      config:
        template:
          source: /etc/consul-template/tmpl-source/haproxy_frontend.cfg.ctmpl
          destination: /opt/haproxy/conf/frontend.cfg
          command: systemctl reload haproxy
