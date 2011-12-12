include_recipe "piwik::default"

template "#{node[:piwik][:install_path]}/piwik/config/config.ini.php" do
  source "config.ini.php.erb"
  owner node[:nginx][:user]
  group node[:nginx][:user]
  mode "0644"
  variables(
      :config => node[:piwik][:config]
  )
  notifies :restart, resources(:service => "php-fastcgi"), :delayed
end