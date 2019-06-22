# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

base:
  '*':
    - elrepo
    - mine.ip4_addrs
  node01.rbjorklin.com:
    - role.consul
    - role.nomad
    - role.haproxy
    #- role.bind
    #- role.ceph
    #- role.vault
    # end roles
    - nomad
    - nomad.server
    - consul
    - consul.ui # Used by haproxy
    - consul.server
    - consul.template
    - consul.template.haproxy
    - consul.service.haproxy
    - bind
    - ceph
    - vault
  node0[23].rbjorklin.com:
    - role.consul
    - role.nomad
    - role.haproxy
    #- role.ceph
    #- role.vault
    # end roles
    - nomad
    - nomad.server
    - consul
    - consul.ui # Used by haproxy
    - consul.server
    - consul.template
    - consul.template.haproxy
    - consul.service.haproxy
    - ceph
    - vault
