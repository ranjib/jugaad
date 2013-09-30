# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jugaad/version'

Gem::Specification.new do |spec|
  spec.name          = "jugaad"
  spec.version       = Jugaad::VERSION
  spec.authors       = ["Ranjib Dey"]
  spec.email         = ["dey.ranjib@gmail.com"]
  spec.description   = %q{Do strange things with chef and etcd and lxc}
  spec.summary       = %q{Several Species of Small Furry Animals Gathered Together in a Cave and Grooving with a Pict}
  spec.homepage      = "https://github.com/ranjib/jugaad"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "lxc-ruby", '>= 0.3.1'
  spec.add_dependency "chef", ">= 11.0.0"
  spec.add_dependency "berkshelf"
  spec.add_dependency "net-scp"
  spec.add_dependency "uuid"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
