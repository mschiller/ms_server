#
# install gem into default ruby of rbenv
#
define :rbenv_install_gem, :name => nil, :version => nil, :for_user => 'deploy', :default_environment_path => "/opt/rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/gems/1.8/bin" do

  user_home = "/home/#{params[:for_user]}"

  execute "install ruby" do
    environment ({'HOME' => "#{user_home}", 'USER' => params[:for_user], 'PATH' => "#{user_home}/.rbenv/shims:#{user_home}/.rbenv/bin:#{params[:default_environment_path]}" })
    version = params[:version] ? "--version #{params[:version]}" : ''

    command "gem install #{params[:gem_name]} #{version} --no-ri --no-rdoc"
    not_if  "HOME='#{user_home}' USER=#{params[:for_user]} PATH=#{user_home}/.rbenv/shims:#{user_home}/.rbenv/bin:#{params[:default_environment_path]} gem list --installed #{params[:gem_name]} #{version}"
  end
end
