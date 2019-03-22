# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

ensure haproxy systemd service exists:
  file.managed:
    - name: /etc/systemd/system/haproxy.service
    - makedirs: True
    - contents: |
        [Unit]
        Description=HAProxy Load Balancer
        After=network.target

        [Service]
        Type=simple
        ExecStartPre=/usr/bin/podman run --network none --name haproxy_check_config --rm -v /opt/haproxy/conf:/usr/local/etc/haproxy:ro haproxy:1.9-alpine haproxy -c -f /usr/local/etc/haproxy
        ExecStart=/usr/bin/podman run --network host --name haproxy --rm -p 80:80 -p 443:443 -p 1936:1936 -v /opt/haproxy/conf:/usr/local/etc/haproxy:ro haproxy:1.9-alpine haproxy -W -db -f /usr/local/etc/haproxy
        ExecReload=/usr/bin/podman kill -s USR2 haproxy
        ExecStop=/usr/bin/podman rm -f haproxy

        [Install]
        WantedBy=multi-user.target

ensure haproxy folder exists:
  file.directory:
    - name: /opt/haproxy/conf
    - makedirs: True

ensure haproxy bootstrap config exists:
  file.managed:
    - name: /opt/haproxy/conf/frontend.cfg
    - source: salt://haproxy/bootstrap.cfg.j2
    - template: jinja
    - makedirs: True
#
#ensure haproxy frontend template exists:
#  file.managed:
#    - name: /etc/consul-template/tmpl-source/haproxy_frontend.cfg.ctmpl
#    - source: salt://haproxy_frontend.cfg.ctmpl.j2
#    - makedirs: True

ensure haproxy enabled and running:
  service.running:
    - name: haproxy
    - enable: True
    - watch:
      - file: ensure haproxy systemd service exists
