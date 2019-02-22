# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

nomad:
  bin_dir: /usr/bin
  version: '0.8.7'
  config_dir: /etc/nomad
  config:
    data_dir: /var/lib/nomad
    # Nodes not bound to consul must be configured to advertise themselves.
    advertise:
      http: "{%- for interface, ips in grains['ip4_interfaces'].items()
                  if interface not in ['lo', 'cni0', 'docker0'] and
                  not interface.startswith('veth') and
                  ips|length > 0 %}
                  {%- if loop.first %}
                    {{- ips[0] -}}
                  {%- endif %}
             {%- endfor %}"
      rpc: "{%- for interface, ips in grains['ip4_interfaces'].items()
                  if interface not in ['lo', 'cni0', 'docker0'] and
                  not interface.startswith('veth') and
                  ips|length > 0 %}
                  {%- if loop.first %}
                    {{- ips[0] -}}
                  {%- endif %}
            {%- endfor %}"
      serf: "{%- for interface, ips in grains['ip4_interfaces'].items()
                  if interface not in ['lo', 'cni0', 'docker0'] and
                  not interface.startswith('veth') and
                  ips|length > 0 %}
                  {%- if loop.first %}
                    {{- ips[0] -}}
                  {%- endif %}
             {%- endfor %}"
    client:
      enabled: True
# Sample configuration for a Consul deployment:
#    consul:
#      ssl: True
#      address: "{{grains['id']}}:8543"
#      token: "deadbeef-dead-beef-dead-beefdeadbee"
#      ca_file: "/srv/certs/ca.crt"
#      cert_file: "/srv/certs/{{grains['id']}}.pem"
#      key_file: "/srv/certs/{{grains['id']}}.key"
#      server_auto_join: True
#      client_auto_join: True
# Sample configuration for TLS encryption:
#    tls:
#      http: True
#      rpc: True
#      ca_file: "/srv/certs/ca.crt"
#      cert_file: "/srv/certs/{{grains['id']}}.pem"
#      key_file: "/srv/certs/{{grains['id']}}.key"
#      verify_server_hostname: True
