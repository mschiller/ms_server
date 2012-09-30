# Required for Chef to manage Ubuntu systems
require_recipe 'ubuntu' if platform?('ubuntu')
require_recipe "build-essential"
require_recipe "git"
require_recipe "screen"
include_recipe "java::openjdk"

%w(libxml++2.6-dev libxslt1-dev zip libssl-dev libxml2-dev  libreadline6-dev libghc6-curl-dev curl libqt4-dev nmap imagemagick python-software-properties runit).each do |pkg|
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

# ssl
directory "#{node[:nginx][:dir]}/cert" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end
node[:certificates].each do |cert|
  name = cert[:name]

  #With Startssl and Nginx:
  #ssl  on;
  #ssl_certificate  /etc/nginx/ssl/ssl.crt;
  #ssl_certificate_key  /etc/nginx/ssl/blog.key;
  #
  #Nginx doesn’t do SSL certificate chaining like Apache2 does. In order to get the ca.pem and sub.class1.server.ca.pem onto your install just append the two files to your certificate file.
  #openssl rsa -in ssl.key -out /etc/nginx/conf/ssl.key
  #curl http://www.startssl.com/certs/sub.class1.server.ca.pem >>ssl.crt
  #curl http://www.startssl.com/certs/ca.pem >>ssl.crt

  cert[:files].each do |key, value|
    user "root"
    group "root"
    template "#{node[:nginx][:dir]}/cert/#{name}_cert.#{key}" do
      source value
    end
  end
end if node[:certificates]

require_recipe "nginx::source"
require_recipe "unicorn"
require_recipe "memcached"
require_recipe "imagemagick::rmagick"
require_recipe "redis"
require_recipe "postfix"

include_recipe "ruby_build"
include_recipe "rbenv::user"

include_recipe "server::ssh"
include_recipe "server::application"
include_recipe "server::bash_support"
#include_recipe "server::backup"
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
#node[:jenkins][:http_proxy][:listen_ports] = [ 443 ]
require_recipe "jenkins"

%w(xvfb).each do |pkg|
  package pkg
end

include_recipe "logrotate"

logrotate_app 'nginx' do
  path      File.join(node[:nginx][:log_dir], "*.log")
  rotate     35
  period     "daily"
  postrotate "test ! -f /var/run/nginx.pid || kill -USR1 `cat /var/run/nginx.pid`"
end

node[:tz] = 'Europe/Berlin'
require_recipe "timezone"

# tests

%w(firefox).each do |pkg|
  package pkg
end

%w(ubufox xul-ext-ubufox).each do |pkg|
  package pkg do
    action :purge
  end
end
