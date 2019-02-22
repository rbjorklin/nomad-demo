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
  config.hostmanager.manage_host = false
  config.hostmanager.include_offline = false

  (1..$nodes).each do |i|
    config.vm.define vm_name = "node0%d" % i do |node|
      node.hostmanager.aliases = "node0%d" % i
      node.vm.box = "centos/7"
      node.vbguest.auto_update = false 
      node.vm.hostname = "node0%d.vagrant.rbjorklin.com" % i
      node.vm.network "private_network", ip: "10.10.10.1%d" % i
      node.vm.synced_folder '.', '/vagrant', disabled: true
      node.vm.provision :salt do |salt|
        salt.install_type = "stable"
        salt.minion_key = "pki/node0%d.vagrant.rbjorklin.com.pem" % i
        salt.minion_pub = "pki/node0%d.vagrant.rbjorklin.com.pub" % i
        salt.colorize = true
      end
    end
  end

  config.vm.define "master" do |node|
    node.hostmanager.aliases = "salt"
    node.vm.box = "centos/7"
    node.vbguest.auto_update = false
    node.vm.hostname = "salt.vagrant.rbjorklin.com"
    node.vm.network "private_network", ip: "10.10.10.10"
    node.vm.synced_folder ".", "/srv", type: "rsync", rsync__exclude: ".git/"
    node.vm.provision :salt do |salt|
      salt.install_type = "stable"
      salt.master_config = "master"
      salt.run_highstate = true
      salt.install_master = true
      salt.colorize = true
      salt.minion_key = "pki/salt.vagrant.rbjorklin.com.pem"
      salt.minion_pub = "pki/salt.vagrant.rbjorklin.com.pub"
      salt.seed_master = seed
      salt.colorize = true
    end
  end

end
