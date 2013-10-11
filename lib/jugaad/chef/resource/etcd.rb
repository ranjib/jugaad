require 'chef/resource'

module Jugaad
  module Chef
    module  Resource

      class Etcd < ::Chef::Resource

        identity_attr :key
        state_attrs :value
        provider_base Jugaad::Chef::Provider::Etcd

        def initialize(name, run_context=nil)
          @resource_name = :etcd
          @action = :set
          @allowed_actions.push(:test_and_set, :delete, :get, :wait)
          @key =nil
          @value = nil
        end

        def key(arg=nil)
          set_or_return(:key, arg, :kind_of => String)
        end

        def value(arg=nil)
          set_or_return(:value, arg, :kind_of => String)
        end

      end
    end
  end
end
