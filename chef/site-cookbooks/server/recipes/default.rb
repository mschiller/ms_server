# Required for Chef to manage Ubuntu systems
require_recipe 'ubuntu' if platform?('ubuntu')
require_recipe "build-essential"
require_recipe "git"
require_recipe "screen"
include_recipe "java::openjdk"

%w(libxml++2.6-dev libxslt1-dev zip libssl-dev libxml2-dev  libreadline6-dev libghc6-curl-dev curl libqt4-dev nmap imagemagick).each do |pkg|
  package pkg
end

%w(apache2).each do |pkg|
  package pkg do
    action :remove
  end
end

gem_package "chef" do
  action :install
end

execute "remove gem source entry for opscode" do
  command "gem sources -r http://gems.opscode.com/"
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
# for development
#iptables_rule "port_postgres" do
#  source 'iptables/port_postgres.erb'
#end

iptables_rule "drop_and_logging" do
  source 'iptables/drop_and_logging.erb'
end

require_recipe "nginx"
require_recipe "unicorn"
require_recipe "memcached"
require_recipe "imagemagick::rmagick"
require_recipe "redis"
require_recipe "postfix"

# only ubuntu 11.x
#execute "special configurations redis" do
#  command "echo \"# special configuration for redis\" >> /etc/sysctl.conf && echo \"sysctl vm.overcommit_memory=1\" >> /etc/sysctl.conf && sysctl vm.overcommit_memory=1"
#end

include_recipe "server::ssh"
include_recipe "server::rbenv"
include_recipe "server::application"
include_recipe "server::bash_support"
include_recipe "server::backup"
include_recipe "server::newrelic"
include_recipe "server::wkhtmltopdf"

package "apache2-utils" do # install htpasswd2
  action :install
end

execute "create passwd file" do
  command "htpasswd -c -b #{node.nginx.dir}/passwd #{node.htpasswd.username} #{node.htpasswd.password}"
  notifies :restart, resources(:service => "nginx")
end

node[:jenkins][:http_proxy][:host_name] = "jenkins.#{node.application.domain}"
node[:jenkins][:http_proxy][:variant] = 'nginx'
require_recipe "jenkins"

require_recipe "piwik"

include_recipe "logrotate"

logrotate_app 'nginx' do
  path      File.join(node[:nginx][:log_dir], "*.log")
  rotate     35
  period     "daily"
  postrotate "test ! -f /var/run/nginx.pid || kill -USR1 `cat /var/run/nginx.pid`"
end

node[:tz] = 'Europe/Berlin'
require_recipe "timezone"

=begin

#require_recipe "postgresql"
#include_recipe "postgresql::server"

todo
1. change linux 'postgres' user password
2. change postgres main user password

Connect to PostgreSQL with psql from the postgres Unix account:

      psql -d template1

    Change the postgres password:

      ALTER USER postgres WITH PASSWORD 'this_is_my_password';
=end
