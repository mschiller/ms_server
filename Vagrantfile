# Provides configuration
$LOAD_PATH << File.expand_path(File.join('..', 'lib'), __FILE__)
require 'vagrant_helper'

Vagrant::Config.run do |config|
  include Automation::VagrantHelper
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.define :application_server do |web_config|

    node = node_settings('config.vagrant')
    node[:public_ssh_key] = `cat ~/.ssh/id_rsa.pub`

    # Every Vagrant virtual environment requires a box to build off of.
    web_config.vm.box = 'ubuntu-1004-server-i386'

    # # Assign this VM to a host only network IP, allowing you to access it via the IP.
    web_config.vm.network("192.168.1.2", :netmask => "255.255.255.0")

    # The url from where the 'web_config.vm.box' box will be fetched if it
    # doesn't already exist on the user's system.
    #web_config.vm.box_url = "http://domain.com/path/to/above.box"

    # Boot with a GUI so you can see the screen. (Default is headless)
    if debug?
      web_config.vm.boot_mode = :gui
    end

    web_config.vm.customize do |vm|
      vm.name        = "application_server"
      vm.memory_size = 512
    end

    # Enable provisioning with chef solo, specifying a cookbooks path (relative
    # to this Vagrantfile), and adding some recipes and/or roles.
    web_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = [ File.join(File.expand_path('..', __FILE__), 'chef', 'site-cookbooks') ]
      chef.add_recipe 'server::deployer_user'
      chef.add_recipe "server"

      # Additional Chef settings
      # merge is used to preserve the default JSON configuration,
      # otherwise it'll all be overwritten
      chef.json.merge!(node)

      # specified cookbooks directory as a shared folder on the virtual machine
      chef.provisioning_path = "/tmp/vagrant-chef"

      # The roles path will be expanded relative to the project directory
      #chef.roles_path = "roles"
      #chef.add_role("web")

      chef.log_level = debug? ? :debug : :info

    end

    #todo web_config.ssh.private_key_path = File.expand_path(File.join('..', 'config', 'vagrant.key'), __FILE__)

    # Forward a port from the guest to the host, which allows for outside
    # computers to access the VM, whereas host only networking does not.

    # Forward a port from the guest to the host, which allows for outside
    # computers to access the VM, whereas host only networking does not.
    web_config.vm.forward_port("web", 80, 8880)
    web_config.vm.forward_port("ssl", 443, 8443)
    web_config.vm.forward_port("ftp", 21, 8821)
    web_config.vm.forward_port("ssh", 22, node['ssh']['port'].to_i, :auto => true)
    #web_config.vm.forward_port("mysql", 3306, 3333)
    #web_config.vm.forward_port("solr", 8981, 9984)

    # Share an additional folder to the guest VM. The first argument is
    # an identifier, the second is the path on the guest to mount the
    # folder, and the third is the path on the host to the actual folder.
    # set current project folder for work with passenger
    #web_config.vm.share_folder("server_config", File.expand_path(File.join('.'), __FILE__))

  end
end

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file ubuntu-1104-server-amd64.pp in the manifests_path directory.
  #
  # An example Puppet manifest to provision the message of the day:
  #
  # # group { "puppet":
  # #   ensure => "present",
  # # }
  # #
  # # File { owner => 0, group => 0, mode => 0644 }
  # #
  # # file { '/etc/motd':
  # #   content => "Welcome to your Vagrant-built virtual machine!
  # #               Managed by Puppet.\n"
  # # }
  #
  # config.vm.provision :puppet do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "ubuntu-1104-server-amd64.pp"
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision :chef_client do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # IF you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
