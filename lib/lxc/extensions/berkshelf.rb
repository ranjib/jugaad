require 'lxc/extensions/chef'
module LXC
  module Extensions
    module Chef

      extend LXC::Extensions::Chef

      def install_berkshelf
        chef_resource(resource: 'package[build-essential]', action: :install)
        chef_resource(resource: 'package[libxml2-dev', action: :install)
        chef_resource(resource: 'package[libxslt-dev]', action: :install)
        chef_resource(resource: 'gem_package[berkshelf]', action: :install, gem_binary: '"/opt/chef/embedded/bin/gem"')
      end

      def berks_install_berksfile(berksfile)
        upload!(berksfile, '/tmp/Berksfile')
        chef_resource(resource: 'execute[install_cookbook]', 
                      command: "/opt/chef/embedded/bin/berks install -b /tmp/Berksfile "
                     )
                
      end

      def berks_install(options)
        berskfile="site :opscode\n"
        options.keys.each do |c|
          berksfile << "cookbook '#{c}'"
          berksfile << "'#{c}'"
          berksfile << "\n"
        end
        ssh!(:command=>"echo ")
      end
    end
  end
end
