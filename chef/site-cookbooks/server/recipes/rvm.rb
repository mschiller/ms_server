
node['rvm']['user_installs'] = [ node[:deployer_user][:username] ]
node['rvm']['user_default_ruby'] = node['rvm']['default_ruby']
node['rvm']['vagrant']['system_chef_solo'] = "/usr/local/rvm/gems/#{node['rvm']['default_ruby']}@global/bin/chef-solo" # /home/#{node[:deployer_user][:username]}/.rvm/gems

node['rvm']['rvmrc'] = {
        'rvm_project_rvmrc' => 1,
        'rvm_gemset_create_on_use_flag' => 1,
        'rvm_trust_rvmrcs_flag' => 1
}

include_recipe "rvm::system" # fixme rvm::user
include_recipe "rvm::vagrant" #if vagrant?
