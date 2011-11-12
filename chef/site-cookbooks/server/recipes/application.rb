
directory "/var/projects/" do
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  mode "0755"
  action :create
end

## fixme install as user with rbenv version
#install_gems :gems => node['rbenv']['gems'],
#             :user => username,
#             :group => username
