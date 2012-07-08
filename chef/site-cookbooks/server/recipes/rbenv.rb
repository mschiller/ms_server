class Chef::Recipe
  # mix in recipe helpers
  include Chef::Rbenv::RecipeHelpers
end

# config
#"rbenv":{
#    "version":"v0.3.0",
#    "default":"1.9.3-p194",
#    "versions":[
#    "1.9.3-p194",
#    "1.8.7-p352"
#],
#    "gems":[
#    {
#        "name":"bundler",
#    "version":"1.1.4"
#},
#    {
#        "name":"rake",
#    "version":"0.9.2.2"
#},
#    {
#        "name":"chef",
#    "version":"0.10.4"
#}
#]
#},

@rbenv_version = node[:rbenv][:version]
@default_environment_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/gems/1.8/bin"

execute "install ruby-build" do
  user node[:deployer_user][:username]
  group node[:deployer_user][:username]
  cwd "/home/#{node[:deployer_user][:username]}"
  command "git clone git://github.com/sstephenson/ruby-build.git && cd ruby-build && sudo ./install.sh"
  not_if do
    File.exists?("/usr/local/bin/ruby-build")
  end
end

execute "update ruby-build" do
  user node[:deployer_user][:username]
  group node[:deployer_user][:username]
  cwd "/home/#{node[:deployer_user][:username]}/ruby-build"
  command "git checkout master && git pull && sudo ./install.sh"
end

(node[:additional_users].to_a + [node[:deployer_user][:username]]).compact.each do |username|

  directory "/home/#{username}" do
    user username
    group username
    mode "0755"
    action :create
  end

  execute "install rbenv" do
    not_if do
      File.exists?("/home/#{username}/.rbenv/README.md")
    end
    user username
    group username
    environment ({'HOME' => "/home/#{username}", 'USER' => username})

    command "git clone git://github.com/sstephenson/rbenv.git /home/#{username}/.rbenv && echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> /home/#{username}/.bash_profile && echo 'eval \"$(rbenv init -)\"' >> /home/#{username}/.bash_profile && exec $SHELL"
  end

  execute "update rbenv" do
    user username
    group username
    environment ({'HOME' => "/home/#{username}", 'USER' => username})
    cwd "/home/#{username}/.rbenv"
    command "git checkout master && git pull && git checkout #{@rbenv_version}"
  end

  node['rbenv']['versions'].each do |rbenv_version|
    execute "install ruby" do
      user username
      group username
      environment ({'HOME' => "/home/#{username}", 'USER' => username, 'PATH' => "/home/#{username}/.rbenv/shims:/home/#{username}/.rbenv/bin:#{@default_environment_path}"})
      cwd "/home/#{username}"
      command "rbenv install #{rbenv_version}; rbenv rehash; exit 0;"
    end
  end

  file "/home/#{username}/.rbenv/default" do
    owner username
    group username
    content node['rbenv']['default']
    action :create
  end

  execute "default as global" do
    user username
    group username
    environment ({'HOME' => "/home/#{username}", 'USER' => username, 'PATH' => "/home/#{username}/.rbenv/shims:/home/#{username}/.rbenv/bin:#{@default_environment_path}"})
    cwd "/home/#{username}"
    command "/home/#{username}/.rbenv/bin/rbenv global #{node['rbenv']['default']}"
  end

  #execute "install rbenv-gemset" do
  #  not_if do
  #    user username
  #    group username
  #    File.exists?("/home/#{username}/.rbenv/plugins/rbenv-gemset")
  #  end
  #  user username
  #  group username
  #  environment ({'HOME' => "/home/#{username}", 'USER' => username, 'PATH' => "/home/#{username}/.rbenv/shims:/home/#{username}/.rbenv/bin:#{@default_environment_path}" })
  #
  #  command "mkdir -p /home/#{username}/.rbenv/plugins && cd /home/#{username}/.rbenv/plugins && git clone git://github.com/jamis/rbenv-gemset.git"
  #end
end
