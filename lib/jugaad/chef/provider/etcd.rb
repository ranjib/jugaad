require 'chef/provider'

module Jugaad
  module Chef
    module  Provider

      class Etcd < ::Chef::Provider

        def initialize(new_resource, run_context)
          super(new_resource, run_context)
        end

        def whyrun_supported?
          true
        end

        def etcd
          @etcd ||= Etcd.client(::Chef::Config[:etcd])
        end
        
        def key_exist?
          exist = true
          begin
            etcd.get(new_resource.key)
          rescue Net::HTTPServerException => e
            exist = false
          end
          exist
        end

        def current_value
          if key_exist?
            etcd.get(new_resource.key)
          else
            nil
          end
        end

        def action_set
          if current_value == new_resource.value
            Chef::Log.debug(" etcd #{new_resource.key} is in sync")
          else
            converge_by "will set value of key #{new_resource.key}" do
              etcd.set(new_resource.key, new_resource.value)
              new_resource.updated_by_last_action(true)
            end
          end
        end

        def action_get
          converge_by "will set value of key #{new_resource.key}" do
            if key_exist?
              current_value
            else
              nil
            end
            new_resource.updated_by_last_action(true)
          end
        end

        def action_test_and_set
          begin
            etcd.test_and_set(new_resource.key, new_resource.value, new_resource.prevValue, ttl)
          rescue Net::HTTPServerException => e
            converge_by "will not be able test_and_set value of key #{new_resource.key}" do
              new_resource.updated_by_last_action(true)
            end
          end
        end

        def wait
          converge_bey "will wait for update from etcd key #{new_resource.key}" do
            etcd.wait(new_resource.key)
            new_resource.updated_by_last_action(true)
          end
        end

        def delete
          if key_exist?
            converge_bey "will delete etcd key #{new_resource.key}" do
              etcd.delete(new_resource.key)
              new_resource.updated_by_last_action(true)
            end
          else
            Chef::Log.debug("etcd key #{new_resource.key} does not exist")
          end
        end
      end
    end
  end
end
