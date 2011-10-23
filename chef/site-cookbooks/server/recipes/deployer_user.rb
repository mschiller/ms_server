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

# Create home directory for the account
directory "/home/#{node[:deployer_user][:username]}" do
  mode 0770
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
