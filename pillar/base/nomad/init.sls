# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

nomad:
  bin_dir: /usr/local/bin
  version: '0.9.3'
  service_hash: 5183f15191500121589f50aea2e10af76e9d6684db72b791f9126ec6855445d5
  config_dir: /etc/nomad.d
  config:
    data_dir: /var/lib/nomad
    bind_addr: "{%- for interface, ips in grains['ip4_interfaces'].items()
                  if interface not in ['lo', 'cni0', 'docker0'] and
                  not interface.startswith('veth') and
                  ips|length > 0 %}
                  {%- if loop.first %}
                    {{- ips[0] -}}
                  {%- endif %}
                {%- endfor %}"
    # Nodes not bound to consul must be configured to advertise themselves.
    client:
      enabled: True
      server_join:
        retry_join:
        {% for _, addrs in salt.saltutil.runner('mine.get', tgt='nomad:config:server:enabled:True', fun='network.ip_addrs', tgt_type='pillar') | dictsort() %}
          - {{ addrs[0] }}
        {% endfor %}
      network_interface: "{%- for interface, ips in grains['ip4_interfaces'].items()
                  if interface not in ['lo', 'cni0', 'docker0'] and
                  not interface.startswith('veth') and
                  ips|length > 0 %}
                  {%- if loop.first %}
                    {{- interface -}}
                  {%- endif %}
             {%- endfor %}"
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
