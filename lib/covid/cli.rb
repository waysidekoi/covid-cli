# frozen_string_literal: true

require 'thor'

module Covid
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'covid version'
    def version
      require_relative 'version'
      puts "v#{Covid::VERSION}"
    end
    map %w(--version -v) => :version

    desc 'get_latest', 'Fetch latest COVID data from the JHU github repo'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def get_latest(*)
      if options[:help]
        invoke :help, ['get_latest']
      else
        require_relative 'commands/get_latest'
        Covid::Commands::GetLatest.new(options).execute
      end
    end
  end
end
