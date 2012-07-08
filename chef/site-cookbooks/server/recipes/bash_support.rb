
(node[:additional_users].to_a + [node[:deployer_user][:username]]).each do |username|

  template "/home/#{username}/.inputrc" do
    owner username
    group username
    source "bash/inputrc.erb"
    mode 0640
  end

  template "/home/#{username}/.bash_profile" do
    owner username
    group username
    source "bash/bash_profile.erb"
    mode 0640
  end

  template "/home/#{username}/.git-completion.bash" do
    owner username
    group username
    source "bash/git-completion.bash.erb"
    mode 0640
  end
end