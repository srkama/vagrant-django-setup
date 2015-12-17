# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
 
  config.vm.box = "base"
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname ="devenv"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder ".", "/src/website"
  config.vm.provision :shell, :path => "install_script.sh"

end
