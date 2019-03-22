#!/bin/bash

#http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hostmanager
vagrant up

vagrant ssh master -c "sudo /bin/bash -c \"yum install -y python-pip ;\
                                           pip install python-consul\""

vagrant ssh master -c "sudo salt '*' test.ping"
vagrant ssh master -c "sudo salt '*' state.apply elrepo,kernel-lt"

vagrant reload

vagrant ssh master -c "sudo salt '*' state.apply rbd-docker-plugin.build"
vagrant ssh master -c "sudo salt '*' state.highstate"

# Create Ceph pool with pg_num set to 128
# http://docs.ceph.com/docs/master/rados/operations/placement-groups/#a-preselection-of-pg-num
vagrant ssh master -c "sudo ceph osd pool create docker 128"

# init pool
vagrant ssh master -c "sudo rbd pool init docker"

# restart rbd-docker-plugin when pool has been created
vagrant ssh master -c "sudo salt '*' cmd.run 'systemctl restart rbd-docker-plugin docker'"

# deploy jenkins in Nomad
vagrant ssh master -c "cd /srv/nomad ; nomad job run jenkins.nomad"

cat << EOF
Temporary override your DNS server by editing /etc/resolv.conf to use "nameserver 10.10.10.10"
Visit Consul UI here: http://consul-ui.vagrant.rbjorklin.com
Visit Nomad UI here: http://nomad.vagrant.rbjorklin.com
Visit Jenkins here: http://jenkins.vagrant.rbjorklin.com
See HAproxy stats here: http://haproxy.vagrant.rbjorklin.com/haproxy/stats
EOF
