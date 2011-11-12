- http://www.vagrantbox.es/
- http://vagrantup.com/docs/multivm.html

alias vagrant="bundle exec vagrant"

vagrant basebox define 'ms_server' 'ubuntu-10.10-server-i386'
vagrant basebox build 'ms_server'

change gems/veewee-0.2.0/lib/veewee/session.rb:263 "localhost" => "127.0.0.1" and it works great.

# TODO

- bundler
- https://github.com/jamis/rbenv-gemset
- http://vagrantup.com/docs/commands.html => ssh_config
- multi server

- https://github.com/abtris/vagrant-hudson

# Links

- http://wiki.opscode.com/display/chef/Resources

- http://wiki.opscode.com/display/chef/Custom+Knife+Bootstrap+Script
- http://wiki.opscode.com/display/chef/Deploy+Resource
- http://blog.afistfulofservers.net/post/3902042503/a-brief-chef-tutorial-from-concentrate
- http://shapeshed.com/journal/using-rbenv-to-manage-rubies/

-------------

`# setup vagrant
gem install vagrant
vagrant box add lucid32 http://files.vagrantup.com/lucid32.box
rails new todo
cd todo
vagrant init lucid32
mate Vagrantfile
vagrant up
vagrant ssh`

# inside virtual machine

`whoami
cd /vagrant
ruby -v
sudo apt-get update
sudo apt-get install build-essential zlib1g-dev curl git-core sqlite3 libsqlite3-dev`

# install rbenv and Ruby 1.9.2

`git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source .bash_profile
git clone git://github.com/sstephenson/ruby-build.git
cd ruby-build/
sudo ./install.sh
rbenv install 1.9.2-p290`

# get Rails running

`cd /vagrant
gem install bundler
rbenv rehash
bundle
bundle exec rails s`

# vagrant commands

`vagrant reload
vagrant status
vagrant suspend
vagrant resume
vagrant halt
vagrant up
vagrant package
vagrant destroy`

# examples


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

