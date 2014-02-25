$:.unshift File.expand_path '../lib', __FILE__
require 'berkshelf/solo'
require 'rake'
require 'rubygems/package_task'
require "rake/testtask"

Gem::PackageTask.new(eval File.read('berkshelf-solo.gemspec')) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

task :build  do
  `rake gem`
end

task :install => [:build] do
   sh "gem install pkg/berkshelf-solo"
   Rake::Task['clobber_package'].execute
end
