node[:wkhtmltopdf] ||= {}
version = node[:wkhtmltopdf][:version] || '0.9.9-static-i386'

execute "install wkhtmltopdf" do
  not_if do
    File.exists?("/usr/bin/wkhtmltopdf-#{version}")
  end
  user 'root'
  group 'root'
  command "wget http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-#{version}.tar.bz2; tar xvjf wkhtmltopdf-#{version}.tar.bz2; sudo chown root:root wkhtmltopdf-i386; sudo mv wkhtmltopdf-i386 /usr/bin/wkhtmltopdf-#{version}; sudo ln -s /usr/bin/wkhtmltopdf-#{version} /usr/bin/wkhtmltopdf"
end
