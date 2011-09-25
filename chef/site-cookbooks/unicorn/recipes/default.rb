
gem_package "unicorn" do
  version node[:unicorn][:version]
end

cookbook_file "/usr/local/bin/unicornctl" do
  mode 0755
end
