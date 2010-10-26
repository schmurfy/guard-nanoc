# encoding: utf-8
module Guard
  class NanocNotifier

    def self.guard_message(result, compiled, skipped, duration)
      message = ''
      if result
        message << "%d compiled, %d skipped\nin %.1f seconds." % [compiled, skipped, duration]
      else
        message << "Site can't be compiled,\nplease check."
      end
      message
    end

    # failed | success
    def self.guard_image(result)
      icon = if result
        :success
      else
        :failed
      end
    end

    def self.notify(result, compiled, skipped, duration)
      message = guard_message(result, compiled, skipped, duration)
      image   = guard_image(result)

      ::Guard::Notifier.notify(message, :title => 'Nanoc site', :image => image)
    end

  end
end