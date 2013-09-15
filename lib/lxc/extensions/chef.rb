require 'chef'
require 'ohai'
require 'chef/knife/bootstrap'
require 'lxc/extensions/ssh'

module LXC
  module Extensions
    module Chef

      extend LXC::Extensions::Ssh

      def chef_installed?
        ssh(command:'chef-client -v').exitstatus == 0
      end

      def install_chef(options={})
        unless chef_installed?
          case options[:platform]
          when :ubuntu
            ssh!(:command=>'sudo apt-get install -y  curl')
          when :rhel
            ssh!(:command=>'sudo yum install -y  curl')
          else
            ssh!(:command=>'sudo apt-get install -y  curl')
          end
          ssh!(:command=>'curl -L https://www.opscode.com/chef/install.sh | sudo bash')
        end
      end

      def ohai(options={})
        install_chef unless chef_installed?
        if options[:refresh]
          @ohai =  ::Chef::JSONCompat.from_json(ssh!(command: 'sudo ohai'))
        else
          @ohai ||= ::Chef::JSONCompat.from_json(ssh!(command: 'sudo ohai'))
        end
        @ohai
      end


      # vm.chef_resource(resource: 'package[curl]', action: :install)
      # vm.chef_resource(resource: 'gem_package[bundler]', action: :install, gem_binary: '"/opt/chef/embedded/bin/gem"')
      def chef_resource(options={})
        install_chef unless chef_installed?
        resource = options.delete(:resource)
        action = options.delete(:action)


        if resource=~/(.*)\[(.*)\]/
          resource_type=$1
          resource_name=$2
          attributes = options.collect do |k,v|
                         "#{k} #{v}"
                       end.join("\n")
          recipe=<<-EOF

            #{resource_type} "#{resource_name}" do
              action :#{action.to_s}
              #{attributes}
            end

          EOF
          File.open('/tmp/recipe.rb', 'w') do |f|
            f.write(recipe)
          end
          upload!(remote_path: '/tmp/recipe.rb', local_path: '/tmp/recipe.rb')
          ssh!(command: 'sudo chef-apply /tmp/recipe.rb')
        else
          raise ArgumentError, "Invalid resource '#{resource}'" 
        end
      end

      def chef_apply_url(url)
        ssh!(:command=>"curl -L #{url}|sudo chef-apply -s")
      end

      def chef_client_run(options={})
        ssh!(:command=>'sudo chef-client')
      end

      def chef_bootstrap(config={})
        ::Chef::Knife::Bootstrap.load_deps
        knife = ::Chef::Knife::Bootstrap.new
        knife.name_args=[ipv4]
        knife.config[:ssh_user] = ssh_user
        knife.config[:ssh_password] = ssh_password
        knife.config[:chef_node_name] = name
        knife.config[:yes] = true
        knife.config[:use_sudo] = true

        ::Chef::Config[:environment] = config[:environment]
        ::Chef::Config.from_file(config[:knife])

        knife.config[:template_file] = config[:template]
        knife.config[:config_file] = config[:knife]
        knife.config[:run_list] = config[:run_list]
        knife.run
      end
    end
  end
end
