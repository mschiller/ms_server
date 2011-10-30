
class Chef::Recipe
  # mix in recipe helpers
  include Chef::Rbenv::RecipeHelpers
end

username = node[:deployer_user][:username]
user_home = "/home/#{username}"
default_environment_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/gems/1.8/bin"

execute "install rbenv" do
  not_if do
    File.directory? ("#{user_home}/.rbenv")
  end
  user username
  group username
  environment ({'HOME' => "#{user_home}", 'USER' => username })

  command "git clone git://github.com/sstephenson/rbenv.git #{user_home}/.rbenv && echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> #{user_home}/.bash_profile && echo 'eval \"$(rbenv init -)\"' >> #{user_home}/.bash_profile && exec $SHELL"
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
  command "git clone git://github.com/sstephenson/ruby-build.git && cd ruby-build && ./install.sh"
  not_if do
    File.exists?("/usr/local/bin/ruby-build")
  end
end

execute "install ruby" do
  user username
  group username
  environment ({'HOME' => "#{user_home}", 'USER' => username, 'PATH' => "#{user_home}/.rbenv/shims:#{user_home}/.rbenv/bin:#{default_environment_path}" })
  cwd "#{user_home}"
  command "rbenv install #{node['rbenv']['default_ruby']}  && rbenv rehash"
  not_if do
    File.exists?("#{user_home}/.rbenv/default")
  end
end
file "#{user_home}/.rbenv/default" do
  owner username
  group username
  content node['rbenv']['default_ruby']
  action :create
end

# fixme install as user with rbenv version
install_gems :global_gems => node['rbenv']['global_gems'],
             :gems => node['rbenv']['gems'],
             :user => username

