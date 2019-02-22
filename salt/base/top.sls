# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

base:
  #(salt|node0[12])\.vagrant\.rbjorklin\.com:
  #  - match: pcre
  '*':
    - consul
    - podman
    - elrepo
    - kernel-lt
    - docker
    - nomad
  #(salt|node0[12])\.vagrant\.rbjorklin\.com:
  #  - match: pcre
  #node0*.vagrant.rbjorklin.com:
  #node0[12].vagrant.rbjorklin.com:
  #  - nginx
  #node0[34].vagrant.rbjorklin.com:
  #  - consul-template
  #  - haproxy
