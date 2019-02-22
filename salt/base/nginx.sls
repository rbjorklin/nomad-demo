# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

ensure nginx systemd service exists:
  file.managed:
    - name: /etc/systemd/system/nginx.service
    - makedirs: True
    - contents: |
        [Unit]
        Description=The nginx HTTP and reverse proxy server
        After=network.target remote-fs.target nss-lookup.target
        
        [Service]
        Type=simple
        #ExecStartPre=/usr/sbin/nginx -t
        ExecStart=/usr/bin/podman run --rm --name nginx -p 80:80 nginx:mainline-alpine
        ExecStop=/usr/bin/podman rm -f nginx
        ExecReload=/bin/kill -s HUP $MAINPID
        
        [Install]
        WantedBy=multi-user.target

ensure nginx enabled and running:
  service.running:
    - name: nginx
    - enable: True
