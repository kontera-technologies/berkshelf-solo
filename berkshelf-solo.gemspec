$:.unshift File.expand_path '../lib', __FILE__
require 'berkshelf/solo/version'
require 'rake'
require 'rubygems/package_task'

Gem::Specification.new do |s|
  s.name                  = "berkshelf-solo"
  s.version               = Berkshelf::Solo::VERSION
  s.platform              = Gem::Platform::RUBY
  s.summary               = "Makes Berkshelf more friendly to chef-solo"
  s.description           = "Makes Berkshelf more friendly to chef-solo by generating chef-solo folder layout"
  s.author                = "Eran Barak Levi"
  s.email                 = "eran@kontera.com"
  s.homepage              = 'http://www.kontera.com'
  s.required_ruby_version = '>= 1.9.1'
  s.rubyforge_project     = "berkshelf-solo"
  s.files                 = %w(README.md Rakefile) + Dir.glob("{lib}/**/*")
  s.require_path          = "lib"

  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'mocha', '~> 0.14'
  s.add_runtime_dependency 'berkshelf', '~> 3.1'
end
