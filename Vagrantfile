# -*- mode: ruby -*-
# vi: set ft=ruby :

CONFIG = File.expand_path("config.rb")
if File.exist?(CONFIG)
  require CONFIG
end

seed = { "salt.vagrant.rbjorklin.com" => "pki/salt.vagrant.rbjorklin.com.pub" }

(1..$nodes).each do |i|
  seed["node0%d.vagrant.rbjorklin.com" % i] = "pki/node0%d.vagrant.rbjorklin.com.pub" % i
end

Vagrant.configure("2") do |config|

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  config.hostmanager.manage_host = true
  config.hostmanager.include_offline = false

  (1..$nodes).each do |i|
    config.vm.define vm_name = "node0%d" % i do |config|
      config.hostmanager.aliases = "node0%d" % i
      config.vm.box = "centos/7"
      config.vm.hostname = "node0%d.vagrant.rbjorklin.com" % i
      config.vm.network "private_network", ip: "10.10.10.1%d" % i
      config.vm.synced_folder '.', '/vagrant', disabled: true
      config.vm.provider "virtualbox" do |vb|
        unless File.exist?("node0%d_additional_disk.vdi" % i)
          vb.customize ['createhd', '--filename', "node0%d_additional_disk" % i, '--size', 5 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', $storage_controller, '--port', 1, '--device', 0, '--type', 'hdd', '--medium', "node0%d_additional_disk.vdi" % i]
        vb.memory = $node_memory
        vb.cpus = $node_cpu_count
      end
      config.vm.provision :salt do |salt|
        salt.install_type = "stable"
        salt.minion_key = "pki/node0%d.vagrant.rbjorklin.com.pem" % i
        salt.minion_pub = "pki/node0%d.vagrant.rbjorklin.com.pub" % i
        salt.colorize = true
      end
    end
  end

  config.vm.define "master" do |config|
    config.hostmanager.aliases = "salt consul-ui.vagrant.rbjorklin.com nomad.vagrant.rbjorklin.com jenkins.vagrant.rbjorklin.com haproxy.vagrant.rbjorklin.com"
    config.vm.box = "centos/7"
    config.vm.hostname = "salt.vagrant.rbjorklin.com"
    config.vm.network "private_network", ip: "10.10.10.10"
    config.vm.synced_folder '.', '/vagrant', disabled: true
    config.vm.synced_folder ".", "/srv", type: "rsync", rsync__exclude: ".git/"
    config.vm.provider "virtualbox" do |vb|
      unless File.exist?("master_additional_disk.vdi")
        vb.customize ['createhd', '--filename', "master_additional_disk", '--size', 5 * 1024]
      end
      vb.customize ['storageattach', :id, '--storagectl', $storage_controller, '--port', 1, '--device', 0, '--type', 'hdd', '--medium', "master_additional_disk.vdi"]
      vb.memory = $node_memory
      vb.cpus = $node_cpu_count
    end
    config.vm.provision :salt do |salt|
      salt.install_type = "stable"
      salt.master_config = "master.yaml"
      #salt.run_highstate = true
      salt.install_master = true
      salt.colorize = true
      salt.minion_key = "pki/salt.vagrant.rbjorklin.com.pem"
      salt.minion_pub = "pki/salt.vagrant.rbjorklin.com.pub"
      salt.seed_master = seed
    end
  end

end
