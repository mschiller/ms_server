
rbenv_install_gem 'backup' do
  gem_name 'backup'
  version  '3.0.21'
end

rbenv_install_gem 'dropbox-sdk' do
  gem_name 'dropbox-sdk'
  version  '1.1.0'
end

rbenv_install_gem 'mail' do
  gem_name 'mail'
  version  '2.2.15'
end

package 'bzip2' do
  action :install
end

directory "/home/#{node[:deployer_user][:username]}/Backup" do
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  mode "0755"
  action :create
end

directory "/home/#{node[:deployer_user][:username]}/Backup/log" do
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  mode "0755"
  action :create
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
  command "mysql -u#{node[:mysql][:server_root_username]} -p#{node[:mysql][:server_root_password]} -e \"GRANT SELECT, SHOW VIEW ON *.* TO '#{node[:backup][:database_username]}'@'#{node[:backup][:from_host]}' IDENTIFIED BY '#{node[:backup][:database_password]}';\""
  action :run
end

template "/home/#{node[:deployer_user][:username]}/bin/backup.sh" do
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  source "backup.sh.erb"
  mode "0700"
  variables(
    {
      backuped_projects: node[:backup][:backuped_projects]
    }.merge!(
      :config_file => "/home/#{node[:deployer_user][:username]}/scripts/backup.rb",
      :user => node[:deployer_user][:username]
    )
  )
end

template "/home/#{node[:deployer_user][:username]}/scripts/backup.rb" do
  owner node[:deployer_user][:username]
  group node[:deployer_user][:username]
  source "backup.rb.erb"
  variables(
    node[:backup].to_hash.merge!(
        {
          mail: node[:backup][:mail],
          backuped_projects: node[:backup][:backuped_projects]
        }
    )
  )
end

cron "cron task for backup" do
  user node[:deployer_user][:username]
  hour '5'
  minute '0'
  #weekday '1'
  command "/home/#{node[:deployer_user][:username]}/bin/backup.sh 2>&1 >/dev/null"
  mailto node[:backup][:mail][:to]
  only_if do File.exist?("/home/#{node[:deployer_user][:username]}/bin/backup.sh") end
end
