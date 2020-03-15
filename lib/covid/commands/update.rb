# frozen_string_literal: true

require_relative '../command'
require 'httparty'
require 'csv'
require 'covid'

module Covid
  module Commands
    class Update < Covid::Command
      COVID_CONFIRMED_PATH = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"
      COVID_DEATHS_PATH = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv"
      COVID_RECOVERED_PATH = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv"
      REPORTS_DATE_FORMAT = "%m/%d/%y"
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
      end

      def execute(input: $stdin, output: $stdout)
        fetch(:confirmed)
        fetch(:deaths)
        fetch(:recovered)

        output.puts "Countries: #{Country.count}"
        output.puts "States: #{State.count}"
      end

      def location_for(row)
        raise "Header for Country/Region doesn't exist" unless row.key?("Country/Region")
        raise "Header for Provice/State doesn't exist" unless row.key?("Province/State")

        country = row["Country/Region"]
        state = row["Province/State"]
        lat = row["Lat"]
        long = row["Long"]

        country = Country.find_by(name: country) || Country.create( Hash.new.tap { |hash|
          hash[:name] = country
          hash[:latitude] = lat unless state # store lat,long at state level
          hash[:longitude] = long unless state # store lat,long at state level
        })

        if state
          name = state_name_for(state)
          s = State.find_by(name: state)
          s ? s : State.create(name: state, latitude: lat, longitude: long, country: country)
        else
          country
        end
      end

      def valid_date?( str, format = REPORTS_DATE_FORMAT)
        Date.strptime(str,format) rescue false
      end

      def state_name_for(string)
        if string.in?(STATES.values)
          # string is an US state
          #
          # Washington
          string
        elsif STATES[string.to_s.split(",").last]
          # lookup US state abbr
          #
          # Pottawattamie, IA
          # Camden, NC
          #
          STATES[string.to_s.split(",").last]
        else
          # Not a US state or state abbr, default to self
          #
          # British Columbia
          # Liaoning
          string
        end
      end

      def fetch(reportable, output=$stdout)
        data_source = case reportable
          when :confirmed then COVID_CONFIRMED_PATH
          when :deaths then COVID_DEATHS_PATH
          when :recovered then COVID_RECOVERED_PATH
        end

        resp = HTTParty.get(data_source)
        CSV.parse(resp.body, headers: true).each do |row|
          location = location_for(row)
          row.to_h.select { |date, count| valid_date?(date) }.each do |date, count|
            report = {
              date: Date.strptime(date, REPORTS_DATE_FORMAT),
              count: count
            }

            location.send(reportable).build(report).tap { |report|
              output.puts "#{reportable.to_s.titleize}: #{location.full_name}, #{report.date}, #{report.count}"
            }
          end

          location.save
        end
      end
    end
  end
end
