include_recipe "piwik::default"

cron "hourly_piwik_archive" do
  minute "12"
  user node[:nginx][:user]
  mailto node[:piwik][:config][:superuser][:email] || "root"
  command "#{node[:piwik][:install_path]}/piwik/misc/cron/archive.sh > /dev/null"
end