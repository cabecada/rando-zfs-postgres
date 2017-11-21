# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  disk = "../disks/dev_vm_zpool.vdi"
  
  config.vm.guest = :freebsd
  config.vm.box = "freebsd/FreeBSD-11.1-STABLE"
  config.vm.base_mac = "080027D14C66"
  config.ssh.shell = "/bin/sh"

  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  config.vm.network "private_network", ip: "10.20.30.40"
  config.vm.network "forwarded_port", guest: 5432, host: 5432

  config.vm.provider :virtualbox do |vb|
    vb.linked_clone = true
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]

    unless File.exist?(disk)
      vb.customize ["createhd", "--filename", disk, "--variant", "Fixed", "--size", 100 * 1024]
    end
    vb.customize ["storageattach", :id,  "--storagectl", "IDE Controller",
                  "--port", 1, "--device", 0, "--type", "hdd", "--medium", disk]
  end

  config.vm.provision "shell", path: "install-packages"
  config.vm.provision "shell", path: "enable-zfs"
  config.vm.provision "shell", path: "enable-postgres"

end
