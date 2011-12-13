
rbenv_install_gem 'backup' do
  gem_name 'backup'
  version  '3.0.19'
  for_user 'deploy'
end

rbenv_install_gem 'dropbox' do
  gem_name 'dropbox'
  version  '1.3.0'
  for_user 'deploy'
end

directory "/home/#{node[:deployer_user][:username]}/bin/" do
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  mode "0755"
  action :create
end
directory "/home/#{node[:deployer_user][:username]}/scripts/" do
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  mode "0755"
  action :create
end

execute "add mysql backup user" do
  command "mysql -u#{node.mysql.server_root_username} -p#{node.mysql.server_root_password} -e \"GRANT SELECT, SHOW VIEW ON *.* TO '#{node.backup.database_username}'@'#{node.backup.from_host}' IDENTIFIED BY '#{node.backup.database_password}';\""
  action :run
end

template "/home/#{node[:deployer_user][:username]}/bin/backup.sh" do
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  source "backup.sh.erb"
  mode "0700"
  variables(
    {
      :backuped_projects => node.backup.backuped_projects
    }.merge!(
      :config_file => "/home/#{node[:deployer_user][:username]}/scripts/backup.rb"
    )
  )
end

template "/home/#{node.deployer_user.username}/scripts/backup.rb" do
  owner node.deployer_user.username
  group node.deployer_user.username
  source "backup.rb.erb"
  variables(
      node.backup.to_hash
  )
end

cron "cron task for backup" do
  user node.deployer_user.username
  hour "5"
  minute "0"
  command "/home/#{node[:deployer_user][:username]}/bin/backup.sh"
  mailto node.backup.mail.to
  only_if do File.exist?("/home/#{node[:deployer_user][:username]}/bin/backup.sh") end
end
