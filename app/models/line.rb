class Line < ApplicationRecord
  serialize :station_list, Array
  serialize :start_times,  Array
  serialize :end_times,    Array

  validates_uniqueness_of :name
  has_many :stops

  # de folosit doar in scaffold-ul stations!
  def stations
    station_list.map {|station_id| Station.find(station_id)}
  end
end
