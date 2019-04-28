#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

uname -a
yum clean all
yum install -y curl vim git

cat >> /etc/hosts << EOF
$3 node01.${2#*.} salt.${2#*.}
$4 node02.${2#*.}
$5 node03.${2#*.}
EOF

INSTALL_MASTER_OPT=""
if [[ $1 -eq 0 ]] ; then
    INSTALL_MASTER_OPT="-M"
fi

curl -so /tmp/bootstrap-salt.sh -L https://bootstrap.saltstack.com
chmod +x /tmp/bootstrap-salt.sh
/tmp/bootstrap-salt.sh ${INSTALL_MASTER_OPT} -i $2 -A salt.${2#*.}

if [[ $1 -eq 0 ]] ; then
    sleep 10
    salt-key -A -y
    salt '*' test.ping
    git clone https://github.com/rbjorklin/nomad-demo.git /srv/
fi
