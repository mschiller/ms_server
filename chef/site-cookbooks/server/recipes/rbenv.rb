
class Chef::Recipe
  # mix in recipe helpers
  include Chef::Rbenv::RecipeHelpers
end

username = node[:deployer_user][:username]
user_home = "/home/#{username}"
rbenv_version = node[:rbenv][:version]
default_environment_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/gems/1.8/bin"

execute "install rbenv" do
  not_if do
    File.directory?("#{user_home}/.rbenv")
  end
  user username
  group username
  environment ({'HOME' => "#{user_home}", 'USER' => username })

  command "git clone git://github.com/sstephenson/rbenv.git #{user_home}/.rbenv && echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> #{user_home}/.bash_profile && echo 'eval \"$(rbenv init -)\"' >> #{user_home}/.bash_profile && exec $SHELL"
end

execute "update rbenv" do
  user username
  group username
  environment ({'HOME' => "#{user_home}", 'USER' => username })

  command "cd #{user_home}/.rbenv && git checkout master && git pull && git checkout #{rbenv_version}" if rbenv_version
end

execute "install rbenv-gemset" do
  not_if do
    File.directory? ("#{user_home}/.rbenv/plugins/rbenv-gemset")
  end
  user username
  group username
  environment ({'HOME' => "#{user_home}", 'USER' => username, 'PATH' => "#{user_home}/.rbenv/shims:#{user_home}/.rbenv/bin:#{default_environment_path}" })

  command "mkdir -p #{user_home}/.rbenv/plugins && cd #{user_home}/.rbenv/plugins && git clone git://github.com/jamis/rbenv-gemset.git"
end

execute "install ruby-build" do
  user username
  group username
  command "cd #{user_home} && git clone git://github.com/sstephenson/ruby-build.git && cd ruby-build && sudo ./install.sh"
  not_if do
    File.exists?("/usr/local/bin/ruby-build")
  end
end

execute "update ruby-build" do
  user username
  group username
  command "cd #{user_home}/ruby-build && git checkout master && git pull && sudo ./install.sh"
end

node['rbenv']['versions'].each do |rbenv_version|
  execute "install ruby" do
    user username
    group username
    environment ({'HOME' => "#{user_home}", 'USER' => username, 'PATH' => "#{user_home}/.rbenv/shims:#{user_home}/.rbenv/bin:#{default_environment_path}" })
    cwd "#{user_home}"
    command "rbenv install #{rbenv_version}  && rbenv rehash"
    not_if do
      File.exists?("#{user_home}/.rbenv/versions/#{rbenv_version}")
    end
  end
end

file "#{user_home}/.rbenv/default" do
  owner username
  group username
  content node['rbenv']['default']
  action :create
end

execute "default as global" do
  user username
      group username
      environment ({'HOME' => "#{user_home}", 'USER' => username, 'PATH' => "#{user_home}/.rbenv/shims:#{user_home}/.rbenv/bin:#{default_environment_path}" })
      cwd "#{user_home}"
      command "rbenv global #{node['rbenv']['default']}"
end

