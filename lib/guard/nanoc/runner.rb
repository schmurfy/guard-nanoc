# encoding: utf-8
module Guard
  class Nanoc
    class Runner
      class << self
        attr_reader :seed

        def set_bundler(options = {})
          @bundler = options[:bundler].nil? ? File.exist?("#{Dir.pwd}/Gemfile") : !!options[:bundler]
        end

        def bundler?
          @bundler = set_bundler if @bundler.nil?
          @bundler
        end

        def set_rubygems(options = {})
          @rubygems = !!options[:rubygems]
        end

        def rubygems?
          @rubygems = set_rubygems if @rubygems.nil?
          bundler? ? false : @rubygems
        end

        def run(options = {})
          message = options[:message] || "Running Nanoc compiler}"
          UI.info message, :reset => true
          system(nanoc_command)
        end

        private

        def nanoc_command
          cmd_parts = []
          cmd_parts << "bundle exec" if bundler?
          cmd_parts << 'ruby'
          cmd_parts << '-r rubygems' if rubygems?
          cmd_parts << '-r bundler/setup' if bundler?
          cmd_parts << "-r #{File.expand_path('../runners/default_nanoc_runner.rb', __FILE__)}"
          cmd_parts << '-e \'DefaultNanocRunner.run\''
          cmd_parts.join(' ')
        end

      end
    end
  end
end

