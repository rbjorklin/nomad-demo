configure consul:
  salt.state:
    - tgt: 'consul:config:server:True'
    - tgt_type: pillar
    - sls:
      - consul
    - pillar:
        consul:
          config:
            retry_join:
            {% for _, addrs in salt.saltutil.runner('mine.get', tgt='consul:config:server:True', fun='network.ip_addrs', tgt_type='pillar') | dictsort() %}
              - {{ addrs[0] }}
            {% endfor %}
