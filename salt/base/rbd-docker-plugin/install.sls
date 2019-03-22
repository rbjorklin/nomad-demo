
install rbd-docker-plugin:
  file.managed:
    - name: /usr/local/bin/rbd-docker-plugin
    - source: salt://rbd-docker-plugin
    - mode: 0755

create service for rbd-docker-plugin:
  file.managed:
    - name: /etc/systemd/system/rbd-docker-plugin.service
    - contents: |
        [Unit]
        Description=Ceph RBD Docker VolumeDriver Plugin
        Wants=docker.service
        Before=docker.service
        
        [Service]
        ExecStart=/usr/local/bin/rbd-docker-plugin -create -remove delete -config /etc/ceph/ceph.conf -plugins /run/docker/plugins -pool docker -size=2048 -cluster ceph -debug -user ceph
        Restart=on-failure
        RestartSec=60
        # NOTE: this kill is not synchronous as recommended by systemd *shrug*
        # disabled for now - having odd plugin issues on reload need to debug further
        #ExecReload=/bin/kill -HUP $MAINPID
        
        [Install]
        WantedBy=multi-user.target

start rbd-docker-plugin:
  service.running:
    - name: rbd-docker-plugin
    - enable: True
