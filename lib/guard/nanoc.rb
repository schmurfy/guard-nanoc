# encoding: utf-8
require 'guard'
require 'guard/guard'

module Guard
  class Nanoc < Guard

    autoload :Runner, 'guard/nanoc/runner'

  end
end
