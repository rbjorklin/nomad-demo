# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

netdata-init-cmd-run:
  cmd.run:
    - name: curl -sSLo- https://my-netdata.io/kickstart-static64.sh | bash -s -- --accept --stable-channel
    - unless: /opt/netdata/bin/netdata -v | grep 1.15.0

{% set d = {} %}
{%- for _, addrs in salt['mine.get']('*', 'network.ip_addrs') | dictsort() -%}
  {%- if loop.first -%}
    {% do d.update({'addr': addrs[0]}) %}
  {%- endif -%}
{%- endfor -%}

netdata-init-file-managed:
  file.managed:
    - name: /opt/netdata/etc/netdata/netdata.conf
    - makedirs: True
    - contents: |
        # netdata can generate its own config which is available at 'http://<netdata_ip>/netdata.conf'
        # You can download it with command like: 'wget -O /opt/netdata/etc/netdata/netdata.conf http://localhost:19999/netdata.conf'

        [registry]
          enabled = {% if d['addr'] in grains['ipv4'] -%} yes {%- else -%} no {%- endif %}
          registry to announce = http://{{ d['addr'] }}:19999

netdata-init-service-running:
  service.running:
    - name: netdata
    - enable: True
    - watch:
      - file: netdata-init-file-managed
