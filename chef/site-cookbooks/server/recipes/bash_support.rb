home = "/home/#{node[:deployer_user][:username]}"

template "#{home}/.inputrc" do
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  source "bash/inputrc.erb"
  mode 0640
end

template "#{home}/.bash_profile" do
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  source "bash/bash_profile.erb"
  mode 0640
end

template "#{home}/.git-completion.bash" do
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  source "bash/git-completion.bash.erb"
  mode 0640
end
