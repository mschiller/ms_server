# Required for Chef to manage Ubuntu systems
require_recipe 'ubuntu' if platform?('ubuntu')

require_recipe "build-essential"
require_recipe "git"
require_recipe "java"
require_recipe "screen"
#require_recipe "god"

%w(libxml++2.6-dev libxslt1-dev zip libssl-dev libxml2-dev  libreadline6-dev libghc6-curl-dev curl libqt4-dev).each do |pkg|
  package pkg
end

node['authorization']['sudo']['users'] =
        node['deployer_user']['username'] = 'deploy'
node['deployer_user']['password_hash'] = 'deploy_pw'

node['rvm']['rvmrc'] = {
  'rvm_project_rvmrc'             => 1,
  'rvm_gemset_create_on_use_flag' => 1,
  'rvm_trust_rvmrcs_flag'         => 1
}

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

# rvm specifics
node['rvm']['user_default_ruby'] = node['rvm']['default_ruby']
node['rvm']['vagrant']['system_chef_solo'] = "/usr/local/rvm/gems/#{node['rvm']['default_ruby']}@global/bin/chef-solo"

require_recipe "mysql"
include_recipe "mysql::server"

require_recipe "postgresql"
include_recipe "postgresql::server"

require_recipe "nginx"
require_recipe "unicorn"
require_recipe "redis"
require_recipe "memcached"

# https://github.com/fnichol/chef-rvm
include_recipe "rvm::system"
include_recipe "rvm::vagrant"

# Recipes for standard server
#include_recipe 'server::deployer_user'
include_recipe 'server::bash_support'


# curl https://raw.github.com/spf13/spf13-vim/master/bootstrap.sh -o - | sh

#rvm_gem "nokogiri" do
#  ruby_string "jruby-1.5.6"
#  version     "1.5.0.beta.4"
#  action      :install
#end

#rvm_shell "migrate_rails_database" do
#  ruby_string "1.8.7-p352@webapp"
#  user        "deploy"
#  group       "deploy"
#  cwd         "/srv/webapp/current"
#  code        %{rake RAILS_ENV=production db:migrate}
#end

#rvm_wrapper "sys" do
#  ruby_string   "jruby@utils"
#  binary        "thor"
#end

#rvm_wrapper "test" do
#  ruby_string   "default@testing"
#  binaries      [ "rspec", "cucumber" ]
#  action        :create
#end

#execute "bundle install" do
#  cwd node[:application][:deploy_to]
#  command "bundle install"
#  action :run
#end

#bash "bundle gems" do
#  code "cd #{node[:application][:deploy_to]} && bundle install"
#end

#execute "create, migrate and seed database" do
##  user node[:deployer_user][:username]
##  group node[:deployer_user][:username]
#  cwd node[:application][:deploy_to]
#  environment "RAILS_ENV" => 'production'
#  command 'rake db:create db:migrate db:seed'
#  action :run
#end

## ruby block example
## http://wiki.opscode.com/display/chef/Resources#Resources-RubyBlock
#ruby_block "do-http-request-with-custom-header" do
#  block do
#    require 'curl'
#    timeout   = 600
#    host      = "localhost"
#    real_host = "" # configatron.production.domain
#    Chef::Log.info "call get on #{host}, maximal request time: #{timeout} seconds"
#    c = Curl::Easy.new("http://#{host}") do |curl|
#      curl.headers['Host'] = real_host
#      curl.verbose         = true
#      curl.timeout         = timeout
#    end
#    c.perform
#    if c.response_code == 200
#      Chef::Log.info "GET success! response was:#{c.body_str}"
#    else
#      Chef::Log.error "GET FAILED. request response was HTTP #{c.response_code}, body: #{c.body_str}"
#    end
#  end
#  action :create
#end
