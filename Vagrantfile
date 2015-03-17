# -*- mode: ruby -*-
# vi: set ft=ruby :

hostname = "app.dev"
server_ip = "192.168.99.110"

server_timezone  = "Pacific/Auckland"
php_timezone = "Pacific/Auckland"

mysql_root_password = "root"

db_name = "app"
db_user = "app_u"
db_pass = "GENERATE_A_REAL_PASSWORD"

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = false
  config.vm.hostname = hostname
  
  # Create a static IP
  config.vm.network :private_network, ip: server_ip
  
  # Use NFS for the shared folder
  config.vm.synced_folder ".", "/vagrant/www",
            id: "core",
            :nfs => true,
            :mount_options => ['nolock,vers=3,udp,noatime'],
            :linux__nfs_options => ['no_root_squash']

  # If using VirtualBox
  config.vm.provider :virtualbox do |vb|

    vb.name = hostname

    # Set server cpus
    vb.customize ["modifyvm", :id, "--cpus", 1]

    # Set server memory
    vb.customize ["modifyvm", :id, "--memory", 1024]

    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    # If the clock gets more than 15 minutes out of sync (due to your laptop going
    # to sleep for instance, then some 3rd party services will reject requests.
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]

    # Prevent VMs running on Ubuntu to lose internet connection
    # vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    # vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

  end

  #config.vm.provision "shell", inline <<-SHELL
  # SHELL

  config.vm.provision "shell", path: "./vagrant/provision.sh", args: [hostname, server_timezone, php_timezone, mysql_root_password, db_name, db_user, db_pass]
end
