require 'net/ssh'
require 'lxc'
require 'net/scp'
require 'lxc/container'
require 'lxc/extensions/core'
require 'lxc/extensions/ssh'
require 'lxc/extensions/chef'

module LXC
  class Container

    # gives container.ipv4
    include LXC::Extensions::Core

    # gives container.ssh container.ssh! container.download!
    include LXC::Extensions::Ssh

    # gives container.chef_install container.chef_bootstrap
    #       container.
    #       
    include LXC::Extensions::Chef
  end
end
