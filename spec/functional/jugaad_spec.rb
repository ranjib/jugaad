require 'spec_helper'
require 'tempfile'
require 'jugaad/lxc/extension'

describe Jugaad do
  describe "lxc" do

    before(:all) do
      LXC.use_sudo = true
      c = LXC::Container.new('test-container')
      c.create(template:'ubuntu',  template_dir: '/usr/share/lxc/templates')
      c.start
      sleep 10
    end

    let(:container) do
      container = LXC::Container.new('test-container')
      container.ssh_user = 'ubuntu'
      container.ssh_password = 'ubuntu'
      container
    end

    describe "core" do
      it "should provide iv4 for individual container" do
        expect(container.ipv4).to_not be_nil
      end
    end

    describe "ssh" do
      it "#ssh!" do
        expect(container.ssh!(command: 'echo -n HelloWorld')).to eq('HelloWorld')
      end
      it "ssh" do
        expect(container.ssh(command: 'ls /root').exitstatus).to_not eq(0)
      end
      it "ssh with sudo" do
        expect(container.ssh(command: 'sudo apt-get update -y').exitstatus).to eq(0)
      end
      it "upload!" do
        tmpfile= Tempfile.new('foo')
        tmpfile.write('foobar')
        tmpfile.close
        expect do
          container.upload!(remote_path: '/home/ubuntu/x', local_path: tmpfile.path)
        end.to_not raise_error
        expect(container.ssh!(command: 'cat /home/ubuntu/x')).to match /foobar/
        tmpfile.unlink
      end

      it "download!" do
        tmpfile= Tempfile.new('foo')
        tmpfile.close
        container.ssh!(command:'echo Bar > /home/ubuntu/x')
        expect do 
          container.download!(remote_path: '/home/ubuntu/x', local_path: tmpfile.path)
        end.to_not raise_error
        expect(container.ssh!(command: 'cat /home/ubuntu/x')).to match /Bar/
        tmpfile.unlink
      end
    end

    describe "chef" do
      it "#install_chef" do
        expect(container.chef_installed?).to be_false
        container.install_chef
        expect(container.chef_installed?).to be_true
      end
      it "#ohai" do
        expect(container.ohai['ipaddress']).to eq(container.ipv4)
      end
      it "#chef_resource" do
        expect(container.ssh(command: 'which tcpdump').exitstatus).to_not eq(0)
        container.chef_resource(resource: 'package[tcpdump]', action: :install)
        expect(container.ssh(command: 'which tcpdump').exitstatus).to eq(0)
      end
      it "#chef_apply" do
      end
    end

    after(:all) do
      c = LXC::Container.new('test-container')
      c.stop
      c.destroy
    end
  end
end
