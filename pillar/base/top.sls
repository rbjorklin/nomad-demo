# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

base:
  '*':
    - elrepo
  salt.vagrant.rbjorklin.com:
    - role.nomad
    - role.consul
    - role.bind
    - role.haproxy
    - role.ceph
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
  node0[12].vagrant.rbjorklin.com:
    - role.nomad
    - role.consul
    - role.ceph
    # end roles
    - nomad
    - nomad.server
    - consul
    - consul.server
    - ceph
