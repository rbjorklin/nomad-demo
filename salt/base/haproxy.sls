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
        ExecStart=/usr/bin/podman run --log-opt path=/dev/null --network host --name haproxy --rm -p 80:80 -p 443:443 -p 1936:1936 -v /opt/haproxy/conf:/usr/local/etc/haproxy:ro haproxy:alpine haproxy -W -db -f /usr/local/etc/haproxy
        ExecReload=/usr/bin/podman kill -s USR2 haproxy
        ExecStop=/usr/bin/podman rm -f haproxy

        [Install]
        WantedBy=multi-user.target

ensure haproxy bootstrap config exists:
  file.managed:
    - name: /opt/haproxy/conf/frontend.cfg
    - source: salt://haproxy/bootstrap.cfg.j2
    - replace: False
    - template: jinja
    - makedirs: True

ensure haproxy enabled and running:
  service.running:
    - name: haproxy
    - enable: True
    - watch:
      - file: ensure haproxy systemd service exists
