
execute "upgrade system" do
  command "apt-get update"
  command "apt-get upgrade -y"
end