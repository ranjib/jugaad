require 'net/ssh'
require 'lxc'
require 'lxc/container'
require 'jugaad/lxc'
require 'jugaad/lxc/extensions/core'
require 'jugaad/lxc/extensions/ssh'
require 'jugaad/lxc/extensions/chef'
require 'jugaad/lxc/extensions/berkshelf'

module LXC
  class Container

    # gives container.ipv4
    include Jugaad::LXC::Extensions::Core

    # gives container.ssh container.ssh! container.download!
    include Jugaad::LXC::Extensions::Ssh

    # gives container.chef_install container.chef_bootstrap
    #       container.
    #       
    include Jugaad::LXC::Extensions::Chef

    include Jugaad::LXC::Extensions::Berkshelf
  end
end
