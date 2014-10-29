# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hetzner-docker/version'

Gem::Specification.new do |spec|
  spec.name          = 'hetzner-docker'
  spec.version       = HetznerDocker::VERSION
  spec.authors       = ['Sergey Melnik']
  spec.email         = ['admin.sa@gmail.com']
  spec.summary       = 'Hetzner servers cli installation'
  spec.description   = 'Configures and installs docker to Hetzner server in\
                        default bootstrap mode, yet has some server management\
                        modes like rescue mode, CentOS and CoreOS installation'
  spec.homepage      = 'https://github.com/iMelnik/hetzner-docker'
  spec.license       = 'GPLv2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_runtime_dependency 'hetzner-api', '~> 1'
  spec.add_runtime_dependency 'net-ssh', '~> 2.9'
  spec.add_runtime_dependency 'net-scp', '~> 1.2'
  spec.add_runtime_dependency 'knife-solo', '~> 0.4'
  spec.add_runtime_dependency 'berkshelf', '~> 3.1'
  spec.add_runtime_dependency 'slop', '~> 3'
end
