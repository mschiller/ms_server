# Required for Chef to manage Ubuntu systems
include_recipe 'ubuntu' if platform?('ubuntu')
include_recipe "build-essential"
include_recipe "git"
include_recipe "screen"
include_recipe "java"

%w(libxml++2.6-dev libxslt1-dev zip libssl-dev libxml2-dev libreadline6-dev libghc-curl-dev curl libqt4-dev nmap imagemagick python-software-properties).each do |pkg|
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

include_recipe "mysql::client"
include_recipe "mysql::server"

include_recipe "iptables"

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

execute "add source for newest nginx" do
  command "add-apt-repository ppa:nginx/stable"
end

include_recipe "nginx"
include_recipe "unicorn"
include_recipe "memcached"
include_recipe "imagemagick::rmagick"
include_recipe "redis"
include_recipe "postfix"

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"
include_recipe "rbenv::rbenv_vars"

rbenv_ruby "1.9.3-p194"

execute "set as default" do
  command "rbenv global 1.9.3-p194"
end

rbenv_install_gem 'bundler' do
  gem_name 'bundler'
end

include_recipe "server::ssh"
include_recipe "server::application"
include_recipe "server::bash_support"
include_recipe "server::backup"
include_recipe "server::newrelic"

package "apache2-utils" do # install htpasswd2
  action :install
end

execute "create passwd file" do
  command "htpasswd -c -b #{node.nginx.dir}/passwd #{node.htpasswd.username} #{node.htpasswd.password}"
  notifies :restart, resources(:service => "nginx")
end

include_recipe "logrotate"

logrotate_app 'nginx' do
  cookbook  'logrotate'
  path      File.join(node[:nginx][:log_dir], "*.log")
  rotate     35
  period     "daily"
  postrotate "test ! -f /var/run/nginx.pid || kill -USR1 `cat /var/run/nginx.pid`"
end

include_recipe "timezone"

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
end
