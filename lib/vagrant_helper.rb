require 'rubygems'
require 'json'

# Support for automation tools.
module Automation
  CONFIG_DIR='config' unless defined? CONFIG_DIR

  # Methods for working with Chef. 
  class VagrantHelper
    def self.json_path(node_name)
      File.join(CONFIG_DIR, "#{node_name}.json")
    end

    def self.node_settings(node_name)
      json = File.read(self.json_path(node_name))
      JSON.parse(json)
    end
  end
end