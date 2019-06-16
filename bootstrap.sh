#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

TF_INSTANCE_INDEX=$1
HOST_NAME=$2
DOMAIN=${HOST_NAME#*.}
TF_INSTANCE_0_IP=$3
TF_INSTANCE_1_IP=$4
TF_INSTANCE_2_IP=$5

uname -a
yum clean all
yum install -y curl vim git

cat >> /etc/hosts << EOF
$TF_INSTANCE_0_IP node01.${DOMAIN} salt.${DOMAIN} salt
$TF_INSTANCE_1_IP node02.${DOMAIN}
$TF_INSTANCE_2_IP node03.${DOMAIN}
EOF

INSTALL_MASTER_OPT=""
if [[ $TF_INSTANCE_INDEX -eq 0 ]] ; then
    INSTALL_MASTER_OPT="-M"
fi

curl -so /tmp/bootstrap-salt.sh -L https://bootstrap.saltstack.com
chmod +x /tmp/bootstrap-salt.sh
/tmp/bootstrap-salt.sh ${INSTALL_MASTER_OPT} -i $HOST_NAME -A salt.${DOMAIN}

if [[ $TF_INSTANCE_INDEX -eq 0 ]] ; then
    yum install -y rng-tools gnupg
    sleep 10
    salt-key -A -y || true
    sleep 3
    salt '*' test.ping || true
    git clone https://github.com/rbjorklin/nomad-demo.git /srv/
    pushd /srv
    sed -i 's#git@#https://#g' .gitmodules
    sed -i 's#m:#m/#g' .gitmodules
    git submodule update --init --recursive
    mkdir -p /etc/salt/gpgkeys
    chmod 0700 /etc/salt/gpgkeys
    gpg --homedir /etc/salt/gpgkeys --batch --gen-key nopasswd_gpg
    gpg --homedir /etc/salt/gpgkeys --armor --export salt-master > exported_pubkey.gpg
    gpg --import exported_pubkey.gpg
    rm -f exported_pubkey.gpg
    popd
fi
