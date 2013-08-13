require 'berkshelf'
require 'berkshelf/dependency'
require 'fileutils'

module Berkshelf
  module Solo
    class Runner

      Berkshelf::Dependency.add_valid_option :recipes
      
      attr_reader :options, :dependencies, :solo_config
      
      def initialize dependencies, cookbook_path
        @dependencies = dependencies
        @options = get_options cookbook_path
        @solo_config = { "run_list" => [] }.merge load_solo_config
      end
      
      def run
        [
          :cookbook_path, 
          :roles_path,
          :environments_path,
          :data_bags_path
        ].map(&options.method(:fetch)).map(&FileUtils.method(:mkdir_p))
        
        dependencies.each do |name, opt|
          solo_config["run_list"] += (opt[:recipes] || ['default']).map {|o| "recipe[#{name}::#{o}]"}
        end
        solo_config["run_list"].uniq!
        
        File.open(options[:solo_config_path],'w') { |f| f.puts JSON.pretty_generate(solo_config) }
        File.open(options[:solo_config_rb_path],'w') { |f| f.puts solo_config_rb }
      end
      
      private 
            
      def load_solo_config
        JSON.parse(File.read(options[:solo_config_path])) rescue Hash.new
      end
      
      def solo_config_rb
        <<-TEXT.gsub(/^\s+/,'')
          file_cache_path File.expand_path(File.dirname(__FILE__))
          cookbook_path File.expand_path('../#{File.basename(options[:cookbook_path])}',__FILE__)
          role_path File.expand_path('../roles',__FILE__)
          environment_path File.expand_path('../environments',__FILE__)
          data_bag_path File.expand_path('../data_bags',__FILE__)
          solo true
        TEXT
      end
      
      def get_options cookbook_path
        base = File.expand_path('..',cookbook_path)
        {
          :path                => base,
          :cookbook_path       => File.expand_path(cookbook_path),
          :roles_path          => File.join(base,'roles'),
          :solo_config_path    => File.join(base,'solo.json'),
          :solo_config_rb_path => File.join(base,'solo.rb'),
          :environments_path   => File.join(base,'environments'),
          :data_bags_path      => File.join(base,'data_bags')
        }
      end
      
    end
  end
end

set_trace_func proc { |_,file,_,_,binding,_|
  if file =~ /Berksfile/i and ARGV.include? "vendor"
    cookbook_path = ARGV[ARGV.index('vendor')+1]
    FileUtils.mkdir_p(File.expand_path('..',cookbook_path))
    Kernel.at_exit { 
      dependencies = Hash[
        eval("@instance",binding).instance_variable_get(:@dependencies).map { |name, dep|
          [name, dep.instance_variable_get(:@options)]
        }
      ]
      Berkshelf::Solo::Runner.new(dependencies,cookbook_path).run
    }
    set_trace_func(nil)
  end
}