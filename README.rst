The startup bootstrap
=====================

.. contents::

What is this?
=============

This is a small PoC for automating the setup of a few software projects one might want
to use when developing and deploying software.

Components used
===============

* Vagrant_ - Repeatable automated development environments
* Ansible_ - Automation & orchestration
* Consul_ - Service mesh to discover & connect services
* Nomad_ - Application scheduler
* Vault_ - Secrets management

Quickstart
==========

See Makefile_ for some available actions.

Setup in Hetzner's Cloud
::

  git clone --recurse-submodules <repo url>
  export TF_VAR_ssh_key="<insert name of hetzner ssh key here>"
  export TF_VAR_hcloud_token="<insert hcloud token here>"
  export TF_VAR_aws_r53_zone_id="<insert zone_id>"
  export AWS_ACCESS_KEY_ID="<access key>"
  export AWS_SECRET_ACCESS_KEY="<secret key>"
  terraform apply


Troubleshooting
===============
In case Vagrant fails to add the extra disks the storage controller might have to be adjusted.
You can find out what your VMs were created with by running:
``VBoxManage list vms | cut -d \  -f 1 | xargs -i VBoxManage showvminfo {} | grep "Storage Controller Name"``
and then update the ``$storage_controller`` field in ``config.rb``

.. _Vagrant: https://www.vagrantup.com/
.. _Ansible: https://www.ansible.com/
.. _Consul: https://www.consul.io/
.. _Nomad: https://www.nomadproject.io/
.. _Vault: https://www.vaultproject.io/
.. _Makefile: Makefile
