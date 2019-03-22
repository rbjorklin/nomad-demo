.. contents:: The startup bootstrap

What is this?
=============

This is a small PoC for automating the setup of a few software projects one might want
to use when developing and deploying software.

Components used
===============

* Vagrant_ - Repeatable automated development environments
* Saltstack_ - Automation & orchestration
* Consul_ - Service mesh to discover & connect services
* Nomad_ - Application scheduler
* Ceph_ - Storage solution for objects, block & filesystems
* Bind_ - Old school DNS server

Test drive the whole shebang
============================

::

  git clone --recurse-submodules <repo url>
  ./setup.sh

Troubleshooting
===============
In case Vagrant fails to add the extra disks the storage controller might have to be adjusted.
You can find out what your VMs were created with by running:
``VBoxManage list vms | cut -d \  -f 1 | xargs -i VBoxManage showvminfo {} | grep "Storage Controller Name"``
and the updating the ``$storage_controller`` field in ``config.rb``

.. _Vagrant: https://www.vagrantup.com/
.. _Saltstack: https://www.saltstack.com/
.. _Consul: https://www.consul.io/
.. _Nomad: https://www.nomadproject.io/
.. _Ceph: https://ceph.com/
.. _Bind: https://www.isc.org/downloads/bind/
