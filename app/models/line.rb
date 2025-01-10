class Line < ApplicationRecord
  serialize :station_list, Array
  serialize :start_times,  Array
  serialize :end_times,    Array

  validates_uniqueness_of :name
  validates_presence_of :start_times, :end_times, :max_time_length, :name, :description, :station_list
  has_many :stops

  # de folosit doar in scaffold-ul stations!
  def stations
    station_list.map {|station_id| Station.find(station_id)}
  end
end
