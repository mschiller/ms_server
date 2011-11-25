#
# Chef-Solo Capistrano Bootstrap
#
# usage:
#   dna_path = dna_path
#   <deploy_user>@<remote_host> = deploy@83.169.36.139
#
#   cap chef:init root@<remote_host>
#   cap chef:bootstrap <dna_path> <deploy_user>@<remote_host>
#   cap chef:install_dna <dna_path> <deploy_user>@<remote_host> => after change of config file
#   cap chef:resolo <deploy_user>@<remote_host>

# configuration
default_run_options[:pty] = true # fix to display interactive password prompts
target = ARGV[-1].split(':')
if (u = ARGV[-1].split('@')[-2])
  set(:user, u)
end
role :target, target[0]
set :port, target[1] || 22
cwd = File.expand_path(File.dirname(__FILE__))
cookbook_dir = '/var/chef-solo'
dna_dir = '/etc/chef'
node = ARGV[-2]

# Provides configuration
$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'vagrant_helper'
extend Automation::VagrantHelper

namespace :chef do
  desc "Bootstrap an Ubuntu 10.04 server and kick-start Chef-Solo"
  task :bootstrap, roles: :target do
    update_system
    install_ruby
    install_chef
    install_cookbook_repo
    install_dna
    solo
  end

  desc "Initialize a fresh Ubuntu install; create users, groups, upload pubkey, etc."
  task :init, roles: :target do
    run "echo '
# /etc/sudoers
#
# This file MUST be edited with the 'visudo' command as root.
#
# See the man page for details on how to write a sudoers file.
#

Defaults  env_reset

# Host alias specification

# User alias specification

# Cmnd alias specification

# User privilege specification
root  ALL=(ALL) ALL

# Uncomment to allow members of group sudo to not need a password
# (Note that later entries override this, so you might need to move
# it further down)
%sudo ALL=NOPASSWD: ALL

# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL

# no password request for following groups or users
%admin ALL = NOPASSWD: ALL

#includedir /etc/sudoers.d
' > /etc/sudoers"
    create_user settings['deploy_user']['username'], settings['deploy_user']['password_hash'], settings['deploy_user']['username'], settings['public_ssh_key']
  end

  desc "install Ruby"
  task :install_ruby, roles: :target do
     sudo 'aptitude install -y ruby1.8-dev ruby1.8 rubygems libopenssl-ruby'
  end

  desc "Install Chef and Ohai gems as root"
  task :install_chef, roles: :target do
    sudo 'gem source -a http://gems.opscode.com/' # fixme test if gem is installed
    sudo 'gem install ohai chef --no-ri --no-rdoc'
    sudo "echo 'export PATH=/var/lib/gems/1.8/bin:$PATH' > /home/#{settings['deploy_user']['username']}/.bashrc"
  end

  desc "Install Cookbook Repository from cwd"
  task :install_cookbook_repo, roles: :target do
    sudo 'aptitude install -y rsync'
    sudo "mkdir -m 0775 -p #{cookbook_dir}"
    sudo "chown #{settings['deploy_user']['username']} #{cookbook_dir}"
    reinstall_cookbook_repo
  end

  desc "Re-install Cookbook Repository from cwd"
  task :reinstall_cookbook_repo, roles: :target do
    rsync cwd + '/chef/', cookbook_dir
  end

  desc "Install ./dna/*.json for specified node"
  task :install_dna, roles: :target do
    sudo 'aptitude install -y rsync'
    sudo "mkdir -m 0775 -p #{dna_dir}"
    sudo "chown #{settings['deploy_user']['username']} #{dna_dir}"
    put %Q(file_cache_path "#{cookbook_dir}"
cookbook_path ["#{cookbook_dir}/cookbooks", "#{cookbook_dir}/site-cookbooks"]
role_path "#{cookbook_dir}/roles"), "#{dna_dir}/solo.rb", via: :scp, mode: "0644"

    # fixme: add dynamic config file and create json live

    reinstall_dna
  end

  desc "Re-install ./dna/*.json for specified node"
  task :reinstall_dna, roles: :target do
    rsync "#{cwd}/#{node}", "#{dna_dir}/dna.json"
  end

  desc "Execute Chef-Solo"
  task :solo, roles: :target do
    sudo_env "chef-solo -c #{dna_dir}/solo.rb -j #{dna_dir}/dna.json -l debug"

    exit # subsequent args are not tasks to be run
  end

  desc "Reinstall and Execute Chef-Solo"
  task :resolo, roles: :target do
    reinstall_cookbook_repo
    reinstall_dna
    solo
  end

  desc "Cleanup, Reinstall, and Execute Chef-Solo"
  task :clean_solo, roles: :target do
    cleanup
    install_chef
    install_cookbook_repo
    install_dna
    solo
  end

  desc "Remove all traces of Chef"
  task :cleanup, roles: :target do
    sudo "rm -rf #{dna_dir} #{cookbook_dir}"
    sudo_env 'gem uninstall -ax chef ohai'
  end
end

# helpers
def create_user(user, pass, group, pubkey)
  run "groupadd #{user}; exit 0"
  run "useradd -s /bin/bash -m -g #{group} -p #{pass} #{user}; exit 0"
  run "usermod -s /bin/bash -a -G sudo #{user}; exit 0"
  run "usermod -s /bin/bash -a -G admin #{user}; exit 0"
  ssh_dir = "/home/#{user}/.ssh"
  run "mkdir -pm700 #{ssh_dir} && touch #{ssh_dir}/authorized_keys && chmod 600 #{ssh_dir}/authorized_keys && echo '#{pubkey}' >> #{ssh_dir}/authorized_keys && chown -R #{user}.#{group} #{ssh_dir}; exit 0"
end

def sudo_env(cmd)
  run "#{sudo} -i #{cmd}"
end

def msudo(cmds)
  cmds.each do |cmd|
    sudo cmd
  end
end

def mrun(cmds)
  cmds.each do |cmd|
    run cmd
  end
end

def rsync(from, to)
  find_servers_for_task(current_task).each do |server|
    puts `rsync -avz -e "ssh -p#{port}" "#{from}" "#{server}:#{to}" \
      --exclude ".svn" --exclude ".git"`
  end
end

def bash(cmd)
  run %Q(echo "#{cmd}" > /tmp/bash)
  run "sh /tmp/bash"
  run "rm /tmp/bash"
end

def bash_sudo(cmd)
  run %Q(echo "#{cmd}" > /tmp/bash)
  sudo_env "sh /tmp/bash"
  run "rm /tmp/bash"
end

def settings
  settings = node_settings('config.server')
  settings['public_ssh_key'] = `cat ~/.ssh/id_rsa.pub`
  settings
end