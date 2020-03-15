# frozen_string_literal: true

require 'thor'
require 'active_support/all'

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

    desc 'compare NAMES...', 'Get the reported numbers for several US state abbreviations or country names'
    long_desc <<-DESC
      Get all the reported Confirmations and Deaths
      of any list of US state abbreviations or country names.
      By default only the last 14 days will be displayed.\n
      Example:\n
      > $ covid compare NJ ny wa china italy
    DESC
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'compare ny nj china iran'
    def compare(*names)
      if options[:help]
        invoke :help, ['compare']
      else
        unless names.present?
          invoke :help, ['compare']
          raise Error.new("Missing state or country, or both") 
        end
        require_relative 'commands/compare'
        Covid::Commands::Compare.new(names, options).execute
      end
    end

    desc 'show [STATE] [COUNTRY]', 'Show reports for State or Country'
    long_desc <<-DESC
      Display reported Confirmations and Deaths
      for any one state or country.
      By default only the last 14 days will be displayed.\n
      Example:\n
      > $ covid show --state=NJ\n
      Example:\n
      > $ covid show --country=italy
    DESC
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    method_option :state, type: :array, banner: "name",
                        desc: "Show reports for state"
    method_option :country, type: :array, banner: "name",
                        desc: "Show reports for country"
    def show
      if options[:help]
        invoke :help, ['show']
      else
        unless options['state'] || options['country']
          invoke :help, ['show']
          raise Error.new("Missing state or country, or both") 
        end
        require_relative 'commands/show'
        Covid::Commands::Show.new(options).execute
      end
    end

    desc 'update', 'Fetch latest SARS-CoV-2 data from the JHU github repo, https://github.com/CSSEGISandData/COVID-19'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def update(*)
      if options[:help]
        invoke :help, ['update']
      else
        require_relative 'commands/update'
        Covid::Commands::Update.new(options).execute
      end
    end
  end
end
