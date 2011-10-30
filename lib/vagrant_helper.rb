require 'rubygems'
require 'json'

# Support for automation tools.
module Automation
  CONFIG_DIR='config' unless defined? CONFIG_DIR

  # Methods for working with Chef. 
  module VagrantHelper
    def json_path(node_name)
      File.join(CONFIG_DIR, "#{node_name}.json")
    end

    def node_settings(node_name)
      json = File.read(json_path(node_name))
      JSON.parse(json)
    end

    def vagrant?
      node['deployer_user']['username'] == 'vagrant'
    end

    def debug?
      ENV['DEBUG'] != nil
    end
  end
end