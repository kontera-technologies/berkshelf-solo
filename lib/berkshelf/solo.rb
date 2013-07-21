require 'berkshelf'
require 'berkshelf/dependency'
require 'optparse'
require 'fileutils'

module Berkshelf
  module Solo
    class Runner

      Berkshelf::Dependency.add_valid_option(:recipes)

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
          opts.on("-p", "--path PATH", "") {|v| @options = get_options(v) }
        end
      end
      
      def options
        @options ||= get_options(File.join(Dir.pwd,"chef","cookbooks"))
      end
      
      def get_options(cookbook_path)
        {
          :cookbook_path => File.expand_path(cookbook_path),
          :path          => File.expand_path('..',cookbook_path),
          :role_path     => File.expand_path('../roles',cookbook_path)
        }
      end
      
    end
  end
end

set_trace_func proc { |_,file,_,_,binding,_|
  if file =~ /Berksfile/i
    Kernel.at_exit { Berkshelf::Solo::Runner.new(eval("@instance",binding),ARGV.clone).run }
    set_trace_func(nil)
  end
}