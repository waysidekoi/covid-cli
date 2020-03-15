# frozen_string_literal: true

require_relative '../command'
require 'active_support/all'
require 'tty-table'
require 'covid'

module Covid
  module Commands
    class Show < Covid::Command
      attr_reader :state, :country, :options

      STATES = {
        "AL" => "Alabama",
        "AK" => "Alaska",
        "AZ" => "Arizona",
        "AR" => "Arkansas",
        "CA" => "California",
        "CO" => "Colorado",
        "CT" => "Connecticut",
        "DE" => "Delaware",
        "DC" => "District Of Columbia",
        "D.C." => "District Of Columbia",
        "FL" => "Florida",
        "GA" => "Georgia",
        "HI" => "Hawaii",
        "ID" => "Idaho",
        "IL" => "Illinois",
        "IN" => "Indiana",
        "IA" => "Iowa",
        "KS" => "Kansas",
        "KY" => "Kentucky",
        "LA" => "Louisiana",
        "ME" => "Maine",
        "MD" => "Maryland",
        "MA" => "Massachusetts",
        "MI" => "Michigan",
        "MN" => "Minnesota",
        "MS" => "Mississippi",
        "MO" => "Missouri",
        "MT" => "Montana",
        "NE" => "Nebraska",
        "NV" => "Nevada",
        "NH" => "New Hampshire",
        "NJ" => "New Jersey",
        "NM" => "New Mexico",
        "NY" => "New York",
        "NC" => "North Carolina",
        "ND" => "North Dakota",
        "OH" => "Ohio",
        "OK" => "Oklahoma",
        "OR" => "Oregon",
        "PA" => "Pennsylvania",
        "PR" => "Puerto Rico",
        "RI" => "Rhode Island",
        "SC" => "South Carolina",
        "SD" => "South Dakota",
        "TN" => "Tennessee",
        "TX" => "Texas",
        "UT" => "Utah",
        "VT" => "Vermont",
        "VA" => "Virginia",
        "WA" => "Washington",
        "WV" => "West Virginia",
        "WI" => "Wisconsin",
        "WY" => "Wyoming"
      }

      def initialize(options)
        @options = options
        @state = state_name_for(Array(options['state']).join(' ').presence)
        @country = Array(options['country']).join(' ').presence
      end

      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...
        location = if state && country
          Country.where('lower(name) = ?', country.downcase).states.first&.where('lower(name) = ?', state.downcase).first
        elsif state
          State.where('lower(name) = ?', state.downcase).first
        elsif country
          Country.where('lower(name) = ?', country.downcase).first
        end

        raise Error.new("Location not found: #{@options}") unless location

        table = setup_table(location, :confirmed)
        output.puts "Confirmed"
        output.print table.render(:unicode, alignment: :right, resize: true)
        output.puts

        table = setup_table(location, :deaths)
        output.puts "Deaths"
        output.print table.render(:unicode, alignment: :right, resize: true)
        output.puts
      end

      def setup_table(location, reportable, days_ago = 14.days.ago)
        data = location.send(reportable).order(:date).where("date > ?", days_ago)

        table = TTY::Table.new(
          header: ['Location'] + data.map { |report| report.date.strftime("%Y-%m-%d") }
        )

        table << [location.full_name] + data.map { |report| report.count }
        table
      end

      def state_name_for(string)
        return nil unless string

        if string.titleize.in?(STATES.values)
          # string is an US state
          #
          # washington => Washington
          string
        elsif STATES[string.to_s.split(",").last.upcase]
          # lookup US state abbr
          #
          # al => AL
          #
          STATES[string.to_s.split(",").last.upcase]
        else
          # Not a US state or state abbr, default to self
          #
          # British Columbia
          # Liaoning
          string
        end
      end
    end
  end
end
