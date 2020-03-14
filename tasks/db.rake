# frozen_string_literal: true
require 'active_record'

namespace :db do
  desc "Recreate the database"
  task "create" do
    require_relative 'migrations'
  end
end
