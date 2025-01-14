class Line < ApplicationRecord
  serialize :station_list, Array
  serialize :times_table,  Hash

  validates_uniqueness_of :name
  validates_presence_of :times_table, :time_threshold, :name, :description, :station_list, :modified_at
  has_many :stops

  # de folosit doar in scaffold-ul stations!
  def stations
    stations = Station.where(id: station_list) # le intoarce in ordinea din BD
    station_list.map { |id| stations.find { |station| station.id == id } }
  end
end
