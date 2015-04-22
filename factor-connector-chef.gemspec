# encoding: UTF-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'factor-connector-chef'
  s.version       = '3.0.0'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Maciej Skierkowski']
  s.email         = ['maciej@factor.io']
  s.homepage      = 'https://factor.io'
  s.summary       = 'Factor.io Connector for Chef'
  s.files         = ['./lib/factor-connector-chef.rb']
  s.license       = 'MIT'
  
  s.require_paths = ['lib']

  s.add_runtime_dependency 'net-ssh','~> 2.9.1'
  s.add_runtime_dependency 'net-scp','~> 1.2.1'
  s.add_runtime_dependency 'chef-api', '~> 0.5.0'
  s.add_runtime_dependency 'deep_merge', '~> 1.0.1'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.4.7'
  s.add_development_dependency 'rspec', '~> 3.2.0'
  s.add_development_dependency 'rake', '~> 10.4.2'
end