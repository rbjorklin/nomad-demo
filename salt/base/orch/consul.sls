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
              - 1.1.1.1
            {% for minion, addrs in salt.saltutil.runnner('mine.get', tgt='consul:config:server:True', fun='network.ip_addrs', tgt_type='pillar') | dictsort() %}
              - {{ addrs[0] }}
              - 1.1.1.1
            {% endfor %}
