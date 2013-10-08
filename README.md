# Jugaad

Jugaad is a collection of ruby helper methods for lxc, chef.

## Installation

Add this line to your application's Gemfile:

    gem 'jugaad'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jugaad

## Usage

### Basic lxc operations
```ruby
require 'jugaad'

LXC.use_sudo = true
container = LXC::Container.new("basic")
# create an ubuntu instance
container.create(template: 'ubuntu'), template_options: ['-r', 'lucid'])
container.start
puts container.ipv4
container.stop
container.destroy
```
### Ssh and scp operations
```ruby
container.ssh_user = 'ubuntu'
container.ssh_password = 'ubuntu'
# execute an ssh command (will raise error on failure)
container.ssh!(command: 'sudo apt-get install -y curl')
# more control
result = container.ssh(command: '/xxx/yyy')
puts result.exitstatus
# upload a file from host to container
container.upload!(local_path: __FILE__, remote_path: "/tmp/#{$0}")
container.download!(local_path: "backup_example.rb", remote_path: "/tmp/#{$0}")
```

### Chef related operations
```ruby
# Check if chef installed inside a container(omnibus)
container.chef_installed?
# Install chef inside a container
container.install_chef
# check all ohai data for the container (as hash)
container.ohai
# execute a single chef resource
container.chef_resource(resource: "package[vim]")
container.chef_resource(resource: "package[apache2]", action: :delete)
#apply a recipe from  an url (gist for a chef server: https://gist.github.com/ranjib/6458717)
container.chef_apply(:url, 'https://www.example.com/recipe.rb')
container.chef_apply(:file, '/local/recipe.rb')
recipe = <<-EOF
  package "something"
  service "another" do
    action :disable
  end
EOF
container.chef_apply(:string, recipe)
# and a block
container.chef_recipe "psychedilic" do
  package "nginx"
  service "nginx" do
    action :stop
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
