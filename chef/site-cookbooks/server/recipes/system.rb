
# no password authentication
execute "change ssh config" do
  command "echo 'PermitRootLogin without-password' >> /etc/ssh/sshd_config &&
           echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config &&
           echo 'ChallengeResponseAuthentication no' >> /etc/ssh/sshd_config &&
           echo 'UsePAM yes' >> /etc/ssh/sshd_config"

  #command "ruby -pi.bak -e \"gsub(/oldtext/, 'newtext')\" *.txt"
end

include_recipe 'server::deployer_user'
include_recipe 'server::bash_support'