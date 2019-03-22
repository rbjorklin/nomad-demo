Nomad demo
==========

See the bundled ``setup.sh`` for setting up the Vagrant environment.

find storage controller:
``VBoxManage list vms | cut -d \  -f 1 | xargs -i VBoxManage showvminfo {} | grep "Storage Controller Name"``
