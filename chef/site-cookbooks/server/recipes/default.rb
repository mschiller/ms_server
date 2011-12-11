# Required for Chef to manage Ubuntu systems
require_recipe 'ubuntu' if platform?('ubuntu')
require_recipe "build-essential"
require_recipe "git"
require_recipe "screen"
include_recipe "java::sun"

#todo require_recipe "god"

%w(libxml++2.6-dev libxslt1-dev zip libssl-dev libxml2-dev  libreadline6-dev libghc6-curl-dev curl libqt4-dev nmap).each do |pkg|
  package pkg
end

gem_package "chef" do
  action :install
end

require_recipe "mysql"
include_recipe "mysql::server"

require_recipe "iptables"

iptables_rule "default_rules" do
  source 'iptables/default_rules.erb'
end

# for development, given by mysql recipe
iptables_rule "port_mysql" do
  source 'iptables/port_mysql.erb'
end

iptables_rule "drop_and_logging" do
  source 'iptables/drop_and_logging.erb'
end

# fixme service status
#require_recipe "postgresql"
#include_recipe "postgresql::server"

package "apache2" do
  action :remove
end

require_recipe "nginx"
require_recipe "unicorn"
require_recipe "memcached"
require_recipe "solr"

require_recipe "imagemagick::rmagick"

require_recipe "redis"

# only ubuntu 11.x
#execute "special configurations redis" do
#  command "echo \"# special configuration for redis\" >> /etc/sysctl.conf && echo \"sysctl vm.overcommit_memory=1\" >> /etc/sysctl.conf && sysctl vm.overcommit_memory=1"
#end

include_recipe "server::ssh"
include_recipe "server::rbenv"
include_recipe "server::application"
include_recipe "server::bash_support"