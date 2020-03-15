# frozen_string_literal: true

module Covid
  class Country < ActiveRecord::Base
    has_many :states
    has_many :deaths, class_name: :Death, foreign_key: :location_id
    has_many :confirmed, class_name: :Confirmed, foreign_key: :location_id
    has_many :recovered, class_name: :Recovery, foreign_key: :location_id

    def full_name
      name
    end
  end
end
