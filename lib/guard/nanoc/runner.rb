# encoding: utf-8
module Guard
  class Nanoc
    class Runner
      class << self
        
        def run(options = {})
          Runner.new(options).run
        end

      end

      def initialize(options = {})
        @options = {
          :bundler => File.exist?("#{Dir.pwd}/Gemfile"),
          :rubygems => false
        }.merge(options)
      end

      def run(options = {})
        message = options[:message] || 'Running Nanoc compiler'
        UI.info message, :reset => true
        system(nanoc_command)
      end

      def bundler?
        @options[:bundler]
      end

      def rubygems?
        !bundler? && @options[:rubygems]
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

