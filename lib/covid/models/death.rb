# frozen_string_literal: true

module Covid
  class Death < Report
    validates_uniqueness_of :date, :scope => :location_id
  end
end
