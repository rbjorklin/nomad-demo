#!/bin/bash

#http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

sudo dnf install -y salt-master

salt-key --gen-keys-dir=pki --gen-keys=salt.vagrant.rbjorklin.com || true

for i in $(seq 1 $(egrep '^\$nodes\s?=\s?[1-9]$' config.rb | egrep -o '[1-9]')) ; do
  salt-key --gen-keys-dir=pki --gen-keys=node0${i}.vagrant.rbjorklin.com || true
done

vagrant plugin install vagrant-hostmanager vagrant-vbguest

vagrant up

vagrant ssh master -c "sudo salt 'node0*' test.ping"
vagrant ssh master -c "sudo salt 'node0*' state.sls elrepo"
vagrant ssh master -c "sudo salt 'node0*' state.sls kernel-lt"

vagrant reload node01 node02 node03 node04

vagrant ssh master -c "sudo salt '*' state.highstate"

echo "Visit Consul UI here: http://10.10.10.10:8500/ui"
echo "See HAproxy stats here: http://10.10.10.13:1936/stats or here: http://10.10.10.14:1936/stats"
