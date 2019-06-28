# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

base:
  #'salt*':
  #  - rbd-docker-plugin.build
  '*':
    #- elrepo
    #- kernel-lt
    - chrony
    - netdata
  'role:ceph':
    - match: pillar
    - ceph
    - ceph.osd
    - ceph.mon
    - ceph.mgr
  'role:consul':
    - match: pillar
    - consul
  'role:vault':
    - match: pillar
    - vault
  'role:nomad':
    - match: pillar
    - nomad
    - docker
    #- rbd-docker-plugin.install
  'role:bind':
    - match: pillar
    - bind
    - bind.config
  'role:haproxy':
    - match: pillar
    - podman
    - haproxy
    - consul-template
