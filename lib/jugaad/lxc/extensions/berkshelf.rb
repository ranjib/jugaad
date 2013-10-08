require 'jugaad/lxc/extensions/chef'
require 'berkshelf'

module Jugaad
  module LXC
    module Extensions
      module Berkshelf

        extend Jugaad::LXC::Extensions::Chef

        def berks_installed?
          ssh(command: '/opt/chef/embedded/bin/berks -v').exitstatus == 0
        end

        def install_berks!
          unless berks_installed?
            chef_recipe "install_berkshelf" do

              package "build-essential"
              package "libxml2-dev"
              package "libxslt-dev"

              gem_package "berkshelf" do
                gem_binary "/opt/chef/embedded/bin/gem"
              end
            end
          end
        end

        def berksfile(name="test", &block)
          berksfile = Berksfile.new(name)
          berksfile.instance_eval do
            block.call
          end
          json = berkfile2json(berksfile)
          ssh!(command: 'berks install -b _berksfile')
        end

        def berksfile2json(berksfile)
          data = []
          berksfile.sources.each do |source|
            {cookbook: source.name}
          end
          JSON.dump(data)
        end



        def write_berksfile(&block)
          x = Berksfile.from_file(&block)
          tmpfile = Tempfile.new('berksfile')
          path =  tmpfile.path
          tmpfile.write(x.to_json)
          tmpfile.close
          upload!(local_path: path, remote_path: '/tmp/'+path)
          tmpfile.unlink
          path
        end

      end
    end
  end
end
