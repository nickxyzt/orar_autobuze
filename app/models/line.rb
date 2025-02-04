class Line < ApplicationRecord
  include Cacheable
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

  # programul estimativ al curselor, calculat!
  # Un hash de tipul {1 => ["06:00", ...], 7 => ["08:00", ...]}
  def estimated_schedule(day)
    day_kind_id = SpecialDay.kind_id_of(day)
    day_kind_name = SpecialDay.new(kind_id: day_kind_id).kind_name
    # Poulam intai hash-ul cu orele fixe din baza de date
    day_estimate_table = {}
    self.times_table[day_kind_name][1].each do |key, value|
      # inlocuim cuvintele "start" si "end" cu id-urile statiilor
      case key
      when "start"
        key = self.station_list[0]
      when "end"
        key = self.station_list[-1]
      end
      day_estimate_table[key] = value
    end
    special_stations_ids = day_estimate_table.keys
    stations_ids         = self.station_list
    nr_of_courses        = day_estimate_table.values.first.size

    stations_ids.each do |station_id|
      day_estimate_table[station_id] ||= []
    end
    
    # nr de curse
    nr_of_courses.times do |index_course|
      # Statiile speciale: start, checkpoint, end
      special_stations_ids.each_with_index do |station_id, index_station|
        if index_station < special_stations_ids.count - 1
          station_start_id    = station_id
          station_end_id      = special_stations_ids[index_station+1]
          station_start_index = stations_ids.index(station_start_id)
          station_end_index   = stations_ids.index(station_end_id)
          intermediary_stations_ids = stations_ids[station_start_index .. station_end_index]
          # Obtinem momentele estimate pentru statiile intermediare
          new_moments = Moment.split(day_estimate_table[station_start_id][index_course], day_estimate_table[station_end_id][index_course], intermediary_stations_ids.count)
          # Le introducem in Hash, fara capetele Array-ului cu momentele noi
          intermediary_stations_ids[1..-2].each_with_index do |station_id, index|
            day_estimate_table[station_id] << new_moments[index]
          end
        end
      end
    end

    return day_estimate_table
  end
end
