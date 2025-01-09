class Line < ApplicationRecord
  validates_uniqueness_of :name
  validate :unique_stations
  serialize :station_list, Array
  has_many :stops

  # de folosit doar in scaffold-ul stations!
  def stations
    station_list.map {|station_id| Station.find(station_id)}
  end

  def max_time_length # lungimea maxima in minute
    60
  end

  private
  def unique_stations
    if station_list.uniq.size != station_list.size
      errors.add :base, "Exista statii duplicat. Adauga in numele lor sufixe (ex: dus, intors) pentru a le face unice."
    end
  end
end
