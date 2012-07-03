
service "newrelic-sysmond" do
  supports :restart => true, :status => false
end

execute "download new relic apt-get list" do
  list = "/etc/apt/sources.list.d/newrelic.list"

  command "wget -O /tmp/548C16BF.gpg http://download.newrelic.com/548C16BF.gpg && wget -O #{list} http://download.newrelic.com/debian/newrelic.list && apt-key add /tmp/548C16BF.gpg && apt-get update && apt-get install newrelic-sysmond && nrsysmond-config --set license_key=#{node.newrelic.license}"
  action :run
  notifies :start, resources(:service => "newrelic-sysmond")
  not_if "test -f #{list}"
end

service "newrelic-sysmond" do
  action [ :enable, :start ]
end

