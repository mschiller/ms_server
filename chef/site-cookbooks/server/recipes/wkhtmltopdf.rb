node[:wkhtmltopdf] ||= {}
version = node[:wkhtmltopdf][:version] || '0.11.0_rc1-static-amd64'

execute "install wkhtmltopdf" do
  not_if do
    File.exists?("/usr/bin/wkhtmltopdf-#{version}")
  end
  user 'root'
  group 'root'
  command "wget https://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-#{version}.tar.bz2; tar xvjf wkhtmltopdf-#{version}.tar.bz2; sudo chown root:root wkhtmltopdf-amd64; sudo mv wkhtmltopdf-amd64 /usr/bin/wkhtmltopdf-#{version}; sudo rm -f /usr/bin/wkhtmltopdf; sudo ln -s /usr/bin/wkhtmltopdf-#{version} /usr/bin/wkhtmltopdf"
end
