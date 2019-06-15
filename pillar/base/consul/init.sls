# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

consul:
  # Start Consul agent service and enable it at boot time
  service: True

  # Set user and group for Consul config files and running service
  user: consul
  group: consul

  version: 1.4.4
  download_host: releases.hashicorp.com

  config:
    server: False
    bind_addr: 0.0.0.0
    advertise_addr: "{%- for interface, ips in grains['ip4_interfaces'].items()
                           if interface not in ['lo', 'cni0', 'docker0'] and
                           not interface.startswith('veth') and
                           ips|length > 0 %}
                           {%- if loop.first %}
                             {{- ips[0] -}}
                           {%- endif %}
                     {%- endfor %}"

    enable_debug: True
    datacenter: vagrant
    encrypt: "878aeZQ2f1V1+JOp17GuhQ=="
    retry_interval: 15s
    retry_join:
      - 116.203.116.179
      - 116.203.116.200
      - 116.203.116.188
    ui: False
    log_level: info
    data_dir: /var/consul
    connect:
      enabled: True
