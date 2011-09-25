
template "/home/vagrant/.inputrc" do
  owner 'vagrant'
  group 'vagrant'
  source "inputrc.erb"
  mode 0640
end
