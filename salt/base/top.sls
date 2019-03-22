# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

base:
  'salt*':
    - rbd-docker-plugin.build
  '*':
    - elrepo
    - kernel-lt
    - chrony
  'role:nomad':
    - match: pillar
    - nomad
    - docker
    - rbd-docker-plugin.install
  'role:consul':
    - match: pillar
    - consul
  'role:haproxy':
    - match: pillar
    - consul-template
    - podman
    - haproxy
  'role:bind':
    - match: pillar
    - bind
    - bind.config
  'role:ceph':
    - match: pillar
    - ceph
    - ceph.osd
    - ceph.mon
    - ceph.mgr
