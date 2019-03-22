# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=yaml:

ceph:
  #cluster_name: rbjorklin # defaults to 'ceph'
  release: mimic

  config:
    file: /etc/ceph/ceph.conf
    global:
      # Set cluster id, use command 'uuidgen' to generate it
      fsid: 0fffffff-35be-40a0-a76e-fff899cb85da
      authentication_type: 'none'

  # Ceph mon list, minimum of 3 is recommended for quorum
  mon_hosts:
    - 10.10.10.10
    - 10.10.10.11
    - 10.10.10.12

  osds:
    # Active OSD device list
    active:
      - /dev/sdb
      # if you want to specify separate journal device
      #- /dev/sdj:/dev/sdb1 # data-path:journal-path

  packages:
    - ceph
