
class Chef
  module Rbenv
    module RecipeHelpers
      def install_gems(opts = {})
        if node['rbenv']['install_gems'] == true || node['rbenv']['install_gems'] == "true"
          # install global gems
          opts[:global_gems].each do |gem|
            gem_package gem[:name] do
              action :install
              version gem[:version] if gem[:version]
            end
          end
        end
      end
    end
  end
end
