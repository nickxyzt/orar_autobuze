class Line < ApplicationRecord
  validates_uniqueness_of :name
  serialize :station_list, Array
  has_many :stops

  def stations
    station_list.map {|station_id| Station.find(station_id)}
  end
end
