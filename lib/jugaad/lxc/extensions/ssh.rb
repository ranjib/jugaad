require 'net/scp'
require 'ostruct'

module Jugaad
  module LXC
    module Extensions
      module Ssh

        attr_accessor :ssh_user, :ssh_password

        def ssh!(options={})
          output = ssh(options)
          raise RuntimeError, output.stderr + "\n-----------\n"+output.stdout if output.exitstatus !=0
          output.stdout
        end

        def download!(options={})
          password = options[:password] || ssh_password
          user = options[:user] || ssh_user
          remote_path = options[:remote_path]
          local_path = options[:local_path]
          Net::SCP.start(ipv4, ssh_user, :password => ssh_password) do |scp|
           scp.download(remote_path, local_path)
          end
        end

        def upload!(options={})
          password = options[:password] || ssh_password
          user = options[:user] || ssh_user
          remote_path = options[:remote_path]
          local_path = options[:local_path]
          Net::SCP.upload!(ipv4, user, local_path, remote_path, :ssh => { :password => password })
        end

        def ssh(options={})
          command = options[:command]
          password = options[:password] || ssh_password
          user = options[:user] || ssh_user
          command.force_encoding('binary') if command.respond_to?(:force_encoding)
          exit_status, out, err = 0, "", ""
          Net::SSH.start(ipv4, user, :password => password) do |ssh|
            channel = ssh.open_channel do |ch|
              ch.request_pty
              ch.exec command do |ch, success|
                raise ArgumentError, "Cannot execute #{command}" unless success
                ch.on_data do |ichannel, data|
                  if data =~ /^\[sudo\] password for/
                    channel.send_data "#{password}\n"
                  else
                   out << data
                  end
                end
                ch.on_extended_data do |c, type, data|
                  err << data
                end
                ch.on_request "exit-status" do |ichannel, data|
                  exit_status = [exit_status, data.read_long].max
                end
              end
            end
            channel.wait
          end
          OpenStruct.new(:exitstatus => exit_status,:stdout=>out, :stderr=>err)
        end
      end
    end
  end
end
