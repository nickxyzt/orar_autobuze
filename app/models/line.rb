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

  # Daca circula in aceasta zi
  # TODO de implementat conditia cand circula in cursul saptamanii,
  # dar nu joia, de exemplu
  def circulates_at?(day)
    day_kind_id = SpecialDay.kind_id_of(day)
    day_kind_name = SpecialDay.new(kind_id: day_kind_id).kind_name
    return !times_table[day_kind_name].nil?
  end

  # Programul estimativ al curselor, calculat!
  # Un Array de Array {["06:00", ...], ["08:00", ...], ...}
  # reprezentand orele pentru fiecare statie in parte,
  # in functie de POZITIA ei in station_list
  # NU se poate folosi un Hash deoarece 
  # aceeasi statie (Spital) apare de 2 ori la aceeasi cursa (3A)!
  def estimated_schedule(day)
    if circulates_at? day
      day_kind_id             = SpecialDay.kind_id_of(day)
      day_kind_name           = SpecialDay.new(kind_id: day_kind_id).kind_name
      # Populam cu array-uri goale
      day_estimate_table      = Array.new(station_list.size) {[]}
      # Luam pozitiile statiilor speciale
      special_station_indexes = self.special_station_indexes(Time.zone.today)

      # Populam cu orele fixe din baza de date
      index = 0
      self.times_table[day_kind_name][1].each do |key, value|
        day_estimate_table[special_station_indexes[index]] = value
        index += 1
      end

      # nr de curse
      nr_of_courses = day_estimate_table[0].size
      nr_of_courses.times do |index_course|
        # Pornim de la statiile care au deja orarul cunoscut (cele speciale)
        special_station_indexes.each_with_index do |index_station, i|
          # Pentru ultima statie nu avem "urmatoarea"
          if index_station != special_station_indexes[-1]
            station_start_index = index_station
            station_end_index   = special_station_indexes[i+1]
            intermediary_station_indexes = (station_start_index..station_end_index).to_a
            # Obtinem momentele estimate pentru statiile intermediare
            new_moments = Moment.split(day_estimate_table[station_start_index][index_course], day_estimate_table[station_end_index][index_course], intermediary_station_indexes.count)
            # Le introducem in Hash, fara capetele Array-ului cu momentele noi
            intermediary_station_indexes[1..-2].each_with_index do |station_index, j|
              day_estimate_table[station_index] << new_moments[j]
            end
          end
        end
      end

      return day_estimate_table
    else
      # Autobuzul nu circula in aceasta zi
      return nil
    end
  end

  # Indexurile liniilor speciale dintr-o zi
  def special_station_indexes(day)
    if circulates_at? day
      day_kind_id = SpecialDay.kind_id_of(day)
      day_kind_name = SpecialDay.new(kind_id: day_kind_id).kind_name
      indexes = []
      
      self.times_table[day_kind_name][1].each do |key, value|
        # inlocuim cuvintele "start" si "end" cu index-urile statiilor
        case key
        when "start"
          indexes << 0 
        when "end"
          indexes << self.station_list.size - 1
        else
          indexes << key
        end
      end
      indexes
    end
  end
end
