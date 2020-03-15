# frozen_string_literal: true

require_relative '../command'
require 'action_view'
require 'tty-table'
require 'covid'

module Covid
  module Commands
    class Compare < Covid::Command
      include ActionView::Helpers::NumberHelper

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
      def initialize(names, options)
        @locations = state_countries_for(names).flatten
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        table = setup_table(@locations, :confirmed)
        output.puts "Confirmed"
        output.print table.render(:unicode, alignment: :right, resize: true)
        output.puts

        table = setup_table(@locations, :deaths)
        output.puts "Deaths"
        output.print table.render(:unicode, alignment: :right, resize: true)
        output.puts
      end

      def setup_table(locations, reportable, days_ago = 14.days.ago)
        table = TTY::Table.new(
          header: ['Location'] + locations.first.send(reportable).order(:date).where("date > ?", days_ago).map { |report| report.date.strftime("%Y-%m-%d") }
        )

        locations.each do |location|
          reports = location.send(reportable).order(:date).where("date > ?", days_ago)
          counts = reports.map.with_index { |report, i|
            if i.zero?
              report.count
            else
              count_with_pct_change(report, reports[i-1])
            end
          }
          table << counts.prepend(location.full_name)
        end
        table
      end

      def count_with_pct_change(reportable_b, reportable_a = nil)
        return reportable_b.count if reportable_a.nil?

        delta = reportable_b.count - (reportable_a.count || 0)
        pct_change = delta.fdiv(reportable_a.count)*100
        symbol = case
                 when delta > 0 then '+'
                 when delta < 0 then '-'
                 when delta.zero? then ''
                 end

        if pct_change.nan? || pct_change.infinite? || pct_change.zero?
          reportable_b.count
        else
          "#{reportable_b.count} (#{symbol}#{number_to_percentage(pct_change, precision: 0)})"
        end
      end

      def state_countries_for(locations)
        locations.each_with_object({}) { |location, memo|
          if STATES[location.upcase]
            # lookup US state abbr
            #
            # al => AL
            state = State.find_by(name: STATES[location.upcase])
            (memo[:states] ||= []) << state if state
          else
            country = Country.find_by(name: location.titleize)
            (memo[:countries] ||= []) << country if country
          end
        }.values
      end
    end
  end
end
