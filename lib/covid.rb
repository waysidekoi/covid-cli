# frozen_string_literal: true

require 'active_record'
require 'active_support/all'
require "covid/version"

module Covid
  class Error < StandardError; end

  def self.root
    Pathname.new(File.dirname(File.dirname(__FILE__)))
  end

  ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: ENV['DATABASE'] || Covid.root.join('db', 'covid.db')
  )
end

require 'covid/models/state'
require 'covid/models/country'
require 'covid/models/report'
require 'covid/models/confirmed'
require 'covid/models/death'
require 'covid/models/recovery'
