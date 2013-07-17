require 'berkshelf'
require 'berkshelf/dependency'
require 'optparse'
require 'fileutils'

module Berkshelf
  module Solo
    class Runner
      def initialize(berkfile, argv)
        @berkfile = berkfile
        parser.parse(argv)
        FileUtils.mkdir_p(options[:path])
      end
      
      def run
        dependencies.each do |name, opt|
          solo[:run_list] += (opt[:recipes] || ['default']).map {|o| "recipe[#{name}::#{o}]"}
        end

        File.open(File.join(options[:path],'solo.json'),'w') { |f| f.puts solo.to_json }
        File.open(File.join(options[:path],'solo.rb'),'w') { |f| solo_rb.map {|k,v| f.puts "#{k} #{v.inspect}"}}
      end
      
      def dependencies
        @dependencies ||= Hash[
          @berkfile.instance_variable_get(:@dependencies).map { |name, dep|
            [name, dep.instance_variable_get(:@options)]
          }
        ]
      end
      
      def solo
        @solo ||= { run_list: [] }
      end
      
      def solo_rb
        @solo_rb ||= {
          'file_cache_path' => options[:path],
          'cookbook_path' => options[:cookbook_path],
          'role_path' => options[:role_path],
          'solo' => true
        }
      end
      
      def parser
        OptionParser.new do |opts|
          opts.on("-p", "--path PATH", "") do |v|
            options[:cookbook_path] = File.expand_path(v)
            options[:path] = File.expand_path('..',options[:cookbook_path])
            options[:role_path] = File.expand_path('../roles',options[:cookbook_path])
          end
        end
      end
      
      def options
        @options ||= {
          :cookbook_path => File.join(Dir.pwd,"chef","cookbooks"),
          :path => File.join(Dir.pwd,"chef"),
          :role_path => File.join(Dir.pwd,"chef","roles")
        }
      end
      
    end
  end
end

set_trace_func proc { |_,file,_,_,binding,_|
  if file =~ /Berksfile/i
    Berkshelf::Dependency.add_valid_option(:recipes)
    Kernel.at_exit { Berkshelf::Solo::Runner.new(eval("@instance",binding),ARGV.clone).run }
    set_trace_func(nil)
  end
}