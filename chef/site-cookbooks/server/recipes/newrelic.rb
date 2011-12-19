
service "newrelic-sysmond" do
  supports :restart => true, :status => false
end

execute "download new relic apt-get list" do
  list = "/etc/apt/sources.list.d/newrelic.list"

  command "wget -O #{list} http://download.newrelic.com/debian/newrelic.list && apt-key adv --keyserver hkp://subkeys.pgp.net --recv-keys 548C16BF && apt-get update && apt-get install newrelic-sysmond && nrsysmond-config --set license_key=#{node.newrelic.license}"
  action :run
  notifies :start, resources(:service => "newrelic-sysmond")
  not_if "test -f #{list}"
end

service "newrelic-sysmond" do
  action [ :enable, :start ]
end

