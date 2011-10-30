
template "/home/#{node[:deployer_user][:username]}/.inputrc" do
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  source "inputrc.erb"
  mode 0640
  not_if do
    File.exists?("/home/#{node[:deployer_user][:username]}/.inputrc")
  end
end
