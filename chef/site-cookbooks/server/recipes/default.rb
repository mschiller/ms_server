if false

  # Required for Chef to manage Ubuntu systems
  require_recipe 'ubuntu' if platform?('ubuntu')

  execute "upgrade system" do
    command "apt-get update"
    command "apt-get upgrade -y"
  end

  require_recipe "build-essential"
  require_recipe "git"
  require_recipe "java"
  require_recipe "screen"

  #todo require_recipe "god"

  %w(libxml++2.6-dev libxslt1-dev zip libssl-dev libxml2-dev  libreadline6-dev libghc6-curl-dev curl libqt4-dev).each do |pkg|
    package pkg
  end

  gem_package "chef" do
    action :install
  end

  node['mysql'] = {
          "server_root_password" => "",
          "tunable" => {"table_cache" => "10",
                        "max_heap_table_size" => "32M",
                        "back_log" => "5",
                        "wait_timeout" => "180",
                        "key_buffer" => "10M",
                        "max_connections" => "20",
                        "net_write_timeout" => "30"}
  }

  require_recipe "mysql"
  include_recipe "mysql::server"

  require_recipe "postgresql"
  include_recipe "postgresql::server"

  require_recipe "nginx"
  require_recipe "unicorn"
  require_recipe "memcached"
  require_recipe "solr"

  require_recipe "redis"

  execute "special configurations redis" do
    command "echo \"# special configuration for redis\" >> /etc/sysctl.conf && echo \"sysctl vm.overcommit_memory=1\" >> /etc/sysctl.conf && sysctl vm.overcommit_memory=1"
  end
end

  include_recipe "server::system"
  include_recipe "server::rbenv"


