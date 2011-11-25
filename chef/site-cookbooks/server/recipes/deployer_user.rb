
gem_package "ruby-shadow" do
  action :install
end

# reload after ruby-shadow install
execute "reload bash" do
  command "exec $SHELL"
end

# fixme template "/etc/sudoers" do
#  mode 0440
#  source "sudoers.erb"
#end

# Creates user account for deployment
user node[:deployer_user][:username] do
  comment "Deployment account"
  home "/home/#{node[:deployer_user][:username]}"
  shell "/bin/bash"
  
  if node[:deployer_user][:password_hash]
    password node[:deployer_user][:password_hash]
  end
  
  action :create
end

# add deploy user to sudoers
group "sudo" do
  members ['deploy']
end

# Create home directory for the account
directory "/home/#{node[:deployer_user][:username]}" do
  mode 0700
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  action :create
end

# Create a .ssh directory for SSH keys
directory "/home/#{node[:deployer_user][:username]}/.ssh" do
  mode 0700
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  action :create
end

# Create ssh authorized key
file "/home/#{node[:deployer_user][:username]}/.ssh/authorized_keys" do
  mode 0700
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  content node[:public_ssh_key]
  action :create
end
