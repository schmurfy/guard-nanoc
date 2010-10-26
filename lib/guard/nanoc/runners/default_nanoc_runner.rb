# encoding: utf-8
#
# Some parts of this code come from Nanoc3 and is licenced under MIT
# with copyright 2007-2010 Denis Defreyne and contributors
#
require 'nanoc3'
require 'nanoc3/cli/logger'
require 'guard/nanoc/notifier'

class DefaultNanocRunner
  attr_reader :site, :compiled_reps, :skipped_reps

  class << self

    def run
      runner = DefaultNanocRunner.new
      runner.run
    end

  end

  def initialize
    @site = Nanoc3::Site.new('.')

    @compiled_reps = 0
    @skipped_reps  = 0
    @rep_times     = {}

    setup_notifications
  end

  def run
    start_at = Time.now

    @compiled_reps = 0
    @skipped_reps  = 0
    @rep_times     = {}

    begin
      puts 'Compiling site...'
      site.compile

      # success
      reps = site.items.map { |i| i.reps }.flatten

      reps.select { |r| !r.compiled? }.each do |rep|
        rep.raw_paths.each do |snapshot_name, filename|
          next if filename.nil?
          duration = @rep_times[filename]
          Nanoc3::CLI::Logger.instance.file(:high, :skip, filename, duration)
          @skipped_reps += 1
        end
      end
      @compiled_reps = reps.size - @skipped_reps
      
      end_at = Time.now - start_at
      puts
      puts "Site compiled in %.2f seconds" % end_at
      # TODO: Guard::Nanoc::Notifier.notify(true, @compiled_reps, @skipped_reps, end_at)

    rescue Exception => e
      # failure
      puts 'Failed to compile site'
      print_error(e)
      # TODO: Guard::Nanoc::Notifier.notify(false, 0, 0, Time.now - start_at)
    end

  end

  private

  def setup_notifications
    Nanoc3::NotificationCenter.on(:rep_written) do |rep, path, is_created, is_modified|
      action = (is_created ? :create : (is_modified ? :update : :identical))
      duration = Time.now - @rep_times[rep.raw_path] if @rep_times[rep.raw_path]
      Nanoc3::CLI::Logger.instance.file(:high, action, path, duration)
    end

    Nanoc3::NotificationCenter.on(:compilation_started) do |rep|
      @rep_times[rep.raw_path] = Time.now
    end

    Nanoc3::NotificationCenter.on(:compilation_ended) do |rep|
      @rep_times[rep.raw_path] = Time.now - @rep_times[rep.raw_path]
    end
  end

  def print_error(error)
    $stderr.puts
    
    # Header
    $stderr.puts '+--- /!\ ERROR /!\ -------------------------------------------+'
    $stderr.puts '| An exception occured while running nanoc. If you think this |'
    $stderr.puts '| is a bug in nanoc, please do report it at                   |'
    $stderr.puts '| <http://projects.stoneship.org/trac/nanoc/newticket> --     |'
    $stderr.puts '| thanks in advance!                                          |'
    $stderr.puts '+-------------------------------------------------------------+'
              
    # Exception and resolution (if any)
    $stderr.puts
    $stderr.puts '=== MESSAGE:'
    $stderr.puts
    $stderr.puts "#{error.class}: #{error.message}"
    resolution = resolution_for(error)
    $stderr.puts "#{resolution}" if resolution
    
    # Compilation stack
    $stderr.puts
    $stderr.puts '=== COMPILATION STACK:'
    $stderr.puts
    if ((self.site && self.site.compiler.stack) || []).empty?
      $stderr.puts "  (empty)"
    else
      self.site.compiler.stack.reverse.each do |obj|
        if obj.is_a?(Nanoc3::ItemRep)
          $stderr.puts "  - [item]   #{obj.item.identifier} (rep #{obj.name})"
        else # layout
          $stderr.puts "  - [layout] #{obj.identifier}"
        end
      end
    end

    # Backtrace
    require 'enumerator'
    $stderr.puts
    $stderr.puts '=== BACKTRACE:'
    $stderr.puts
    $stderr.puts error.backtrace.to_enum(:each_with_index).map { |item, index| "  #{index}. #{item}" }.join("\n")
  end

  def resolution_for(error)
    case error
    when LoadError
      # Get gem name
      lib_name = error.message.match(/no such file to load -- ([^\s]+)/)[1]
      gem_name = GEM_NAMES[$1]
   
      # Build message
      if gem_name
        "Try installing the '#{gem_name}' gem (`gem install #{gem_name}`) and then re-running the command."
      end
    when RuntimeError
      if error.message =~ /^can't modify frozen/
        "You attempted to modify immutable data. Some data, such as " \
        "item/layout attributes and raw item/layout content, can no " \
        "longer be modified once compilation has started."
      end
    end
  end

end
