# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

base:
  '*':
    - elrepo
    - mine.ip4_addrs
    - firewalld
    - firewalld.hetzner-nbg1
    - firewalld.haproxy
  node01.rbjorklin.com:
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
  node02.rbjorklin.com:
    - role.bind
    - bind
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
