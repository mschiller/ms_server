#
# Cookbook Name:: piwik
# Recipe:: default
#
# Copyright 2011, gutefrage.net GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "mysql::client"

include_recipe "nginx::source"
template "#{node[:nginx][:dir]}/sites-available/piwik" do
  source "nginx-site-piwik.erb"
  owner  "root"
  group  "root"
  mode   "0644"
  variables(
      :php_fcgi_pass => node[:piwik][:php_fcgi_pass],
      :piwik_install_path => node[:piwik][:install_path]
  )
  notifies :restart, resources(:service => "nginx")
end

bash "enable piwik site" do
  user     "root"
  cwd      node[:nginx][:dir]
  code     "nxensite piwik"
  not_if   "ls #{node[:nginx][:dir]}/sites-enabled/piwik"
  notifies :restart, resources(:service => "nginx")
end

#include_recipe "logrotate"
#logrotate_app 'nginx' do
#  paths      File.join(node[:nginx][:log_dir], "*.log")
#  rotate     35
#  period     "daily"
#  postrotate "test ! -f /var/run/nginx.pid || kill -USR1 `cat /var/run/nginx.pid`"
#end
#
#include_recipe "iptables"
#iptables_rule "iptables_http"

%w(php5-cgi php5-cli php5 php5-gd php5-mysql).each {|pkg| package pkg }

include_recipe "runit"
runit_service "php-fastcgi" do
  options :bind_path => node[:piwik][:php_fcgi_bind_path]
  env "PHP_FCGI_CHILDREN" => node[:piwik][:php_fcgi_children], "PHP_FCGI_MAX_REQUESTS" => node[:piwik][:php_fcgi_max_requests]
  notifies :restart, resources(:service => :nginx), :delayed
end

template "/etc/php5/cgi/php.ini" do
  source "php.ini.erb"
  owner  "root"
  group  "root"
  mode   "0644"
  variables(
      :memory_limit => node[:piwik][:php_fcgi_memory_limit]
  )
  notifies :restart, resources(:service => "php-fastcgi"), :delayed
end

piwik_version = node[:piwik][:version]

remote_file "#{Chef::Config[:file_cache_path]}/piwik-#{piwik_version}.tar.gz" do
  source "http://builds.piwik.org/piwik-#{piwik_version}.tar.gz"
  action :create_if_missing
end

directory node[:piwik][:install_path] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

bash "install_piwik" do
  cwd Chef::Config[:file_cache_path]
  user 'root'
  code <<-EOH
    tar zxf piwik-#{piwik_version}.tar.gz
    mv piwik #{node[:piwik][:install_path]}
    echo '#{piwik_version}' > #{node[:piwik][:install_path]}/piwik/VERSION
  EOH
  not_if "test `cat #{node[:piwik][:install_path]}/piwik/VERSION` = #{piwik_version}"
end
