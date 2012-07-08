
# no password authentication
execute "change ssh config" do
  command "ruby -pi.bak -e \"gsub(/PermitRootLogin .*/, 'PermitRootLogin no')\" /etc/ssh/sshd_config &&
           ruby -pi.bak -e \"gsub(/PasswordAuthentication .*/, 'PasswordAuthentication no')\" /etc/ssh/sshd_config &&
           ruby -pi.bak -e \"gsub(/ChallengeResponseAuthentication .*/, 'ChallengeResponseAuthentication no')\" /etc/ssh/sshd_config &&
           ruby -pi.bak -e \"gsub(/UsePAM .*/, 'UsePAM yes')\" /etc/ssh/sshd_config"
  action :run
  notifies :restart, "service[ssh]"
end

service "ssh"

  ## run "sed -ir 's/^\\(AllowUsers\\s\\+.\\+\\)$/\\1 #{user}/' /etc/ssh/sshd_config"
  #run "echo \"AllowUsers #{user} \"|cat - /etc/ssh/sshd_config > /tmp/out && mv /tmp/out /etc/ssh/sshd_config"

#private
#
#usage: replace_pattern 'UsePAM no', 'UsePAM yes', '/etc/ssh/sshd_config'
#def replace_pattern(search_regexp, replace_string, file)
#command "ruby -pi.bak -e \"gsub(/#{search_regexp}/, '#{replace_string}')\" #{file}"
#end
