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
        "DC" => "District of Columbia",
        "D.C." => "District of Columbia",
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
        update_us(:confirmed)
        update_us(:deaths)
        update_us(:recovered)

        output.puts "Countries: #{Country.count}"
        output.puts "States: #{State.count}"
      end

      def location_for(row)
        raise "Header for Country/Region doesn't exist" unless row.key?("Country/Region")
        raise "Header for Provice/State doesn't exist" unless row.key?("Province/State")

        country = row["Country/Region"]
        province_state = row["Province/State"]
        lat = row["Lat"]
        long = row["Long"]

        country = Country.find_by(name: country) || Country.create( Hash.new.tap { |hash|
          hash[:name] = country
          hash[:latitude] = lat unless province_state # store lat,long at state level
          hash[:longitude] = long unless province_state # store lat,long at state level
        })

        if province_state
          name = us_state_name_for(province_state) || province_state
          s = State.find_by(name: name)
          s ? s : State.create(name: name, latitude: lat, longitude: long, country: country)
        else
          country.tap { |c| c.update(latitude: lat, longitude: long) }
        end
      end

      def valid_date?( str, format = REPORTS_DATE_FORMAT)
        Date.strptime(str,format) rescue false
      end

      def us_state_name_for(string)
        if string.in?(STATES.values)
          # string is an US state
          #
          # Washington
          string
        else
          # lookup US state via US state abbr
          #
          # Pottawattamie, IA
          # Camden, NC
          #
          us_state_name_for_full_state_abbr_string(string)
        end
      end

      def us_state_name_for_full_state_abbr_string(abbr)
        # lookup US state via US state abbr
        #
        # Pottawattamie, IA
        # Camden, NC
        #
        STATES[abbr.to_s.split(",").last.strip]
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

            if location.name == "US"
              require 'pry'; binding.pry
            end
            location.send(reportable).build(report).tap { |report|
              output.puts "#{reportable.to_s.titleize}: #{location.full_name}, #{report.date}, #{report.count}"
            }
          end

          location.save
        end

        rename_taiwan
        update_us(reportable)
      end

      def rename_taiwan
        country = Country.find_by(name: "Taiwan*")
        if country
          country.update(name: "Taiwan")
        end
      end

      def update_us(reportable)
        #
        # The source data intially had US numbers by county, state. Then, later
        # rolled those numbers up into their own US State row. Gracefully
        # ensure numbers aren't double counted, and all history is preserved.
        #
        data_source = case reportable
          when :confirmed then COVID_CONFIRMED_PATH
          when :deaths then COVID_DEATHS_PATH
          when :recovered then COVID_RECOVERED_PATH
        end

        resp = HTTParty.get(data_source)
        csv = CSV.parse(resp.body, headers: true)
        #
        # => ["1/22/20",
        #  "1/23/20",
        #  "1/24/20",
        #  "1/25/20",
        #  "1/26/20",
        #  "1/27/20",
        #
        all_dates = csv.headers.select { |date| valid_date?(date) }

        data = all_dates.each_with_object([]) do |date, memo|
          country_column = "Country/Region"
          state_column = "Province/State"
          parsed_date = Date.strptime(date, REPORTS_DATE_FORMAT)
          date_of_aggregated_state_reporting_switchover = Date.new(2020, 3, 10)

          count = STATES.values.uniq.map { |state_name|
            aggregated_state_row = csv.find { |row| row[country_column] == "US" && row[state_column] == state_name }
            counties = csv.select { |row| row[country_column] == "US" && us_state_name_for_full_state_abbr_string(row[state_column]) == state_name }

            counties_sum = counties.map { |county| county[date].to_i }.sum
            aggregated_state_sum = aggregated_state_row[date].to_i

            if parsed_date >= date_of_aggregated_state_reporting_switchover
              aggregated_state_row[date].to_i
            else
              counties_sum
            end
          }.sum
          memo << {
            date: parsed_date,
            count: count
          }
        end

        us = Country.find_by(name: "US")
        us.send(reportable).destroy_all
        us.send(reportable).build(data)
      end
    end
  end
end
