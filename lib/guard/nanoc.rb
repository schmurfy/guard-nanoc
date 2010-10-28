# encoding: utf-8
require 'guard'
require 'guard/guard'

module Guard
  class Nanoc < Guard

    autoload :Runner, 'guard/nanoc/runner'

    def initialize(watchers = [], options = {})
      super

      @runner = Runner.new(options)
    end

    def start
      true
    end

    def stop
      true
    end

    def reload
      true
    end

    def run_all
      @runner.run
    end

    def run_on_change(paths = [])
      @runner.run
    end

  end
end
