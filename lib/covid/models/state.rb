# frozen_string_literal: true

module Covid
  class State < ActiveRecord::Base
    belongs_to :country

    has_many :deaths, class_name: :Death, foreign_key: :location_id
    has_many :confirmed, class_name: :Confirmed, foreign_key: :location_id
    has_many :recovered, class_name: :Recovery, foreign_key: :location_id

    def full_name
      "#{name}, #{country.name}"
    end
  end
end
