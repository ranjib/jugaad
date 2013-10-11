require 'net/http/exceptions'
require 'jugaad/lxc/extensions/chef'
require 'etcd'
require 'json'

module Jugaad
  module LXC
    module Extensions
      module Etcd
        extend Chef

        def etcd_installed?
          not @etcd.nil?
        end

        def install_etcd!(options={})
          @etcd ||= ::Etcd.client(options)
        end
        
        def etcd_set(key, value, ttl=nil)
          @etcd.set(key, value, ttl)
        end

        def etcd_get(key)
          if key_exist?(key)
            @etcd.get(key)
          else
            nil
          end
        end

        def etcd_delete(key)
          @etcd.delete(key)
        end

        def etcd_watch(key, options={})
          @etcd.watch(key, options)
        end

        def etcd_test_and_set(key, value, prevValue, ttl = nil)
          @etcd.test_and_set(key, value, prevValue, ttl = nil)
        end

        def etcd_eternal_watch(key, index=nil)
          @etcd.eternal_watch(key, index=nil)
        end

        def etcd_lock(options={})
          @etcd.lock(options)
        end

        def publish!
          key = '/nodes/'+name+'/metadata'
          data = etcd_get(key)
          past_metadata =  data.nil? ? {} : JSON.parse(data.value)

          unless metadata == past_metadata
            etcd_set( key, JSON.dump(metadata))
          else
            data
          end
        end

        def metadata
          {'ipv4'=> ipv4}
        end

        def etcd_node(name)
          response = @etcd.get('/nodes/'+name+'/metadata')
          JSON.parse(response.value)
        end

        def key_exist?(key)
          exist = true
          begin
            @etcd.get(key)
          rescue Net::HTTPServerException => e
            exist = false
          end
          exist
        end
      end
    end
  end
end
