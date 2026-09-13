class Line < ApplicationRecord
  include Cacheable
  serialize :station_list, Array
  serialize :times_table,  Hash

  validates_uniqueness_of :name
  validates_presence_of :times_table, :time_threshold, :name, :description, :station_list, :modified_at
  has_many :stops

  SIMPLE_SCHEDULE = {"working" => [[1,2,3,4,5], []], "holiday" => [[0,6], []]} # un orar valid dar foarte simplu

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
    day_kind_name = SpecialDay.new(kind_id: day_kind_id).kind_name.to_s
    return !times_table[day_kind_name].nil?
  end

  # Programul estimativ al curselor, calculat unde nu este prestabilit!
  # Un Array de Array {["06:00", ...], ["08:00", ...], ...}, dublu
  # (orele de SOSIRE si orele de PLECARE)
  # in functie de POZITIA statiei in line.station_list
  # NU se poate folosi un Hash deoarece 
  # aceeasi statie poate aparea de 2 ori la aceeasi cursa (ex: Spital la 3A)!
  def estimated_schedule(day)
    if circulates_at? day
      day_kind_id             = SpecialDay.kind_id_of(day)
      day_kind_name           = SpecialDay.new(kind_id: day_kind_id).kind_name.to_s
      # Ne folosim de orele de start ale curselor - ele trebuie sa existe obligatoriu la toate cursele
      start_times_table         = self.times_table[day_kind_name][1].first[1]

      # Populam cu array-uri goale pentru fiecare STATIE
      day_estimate_table_arrivals   = Array.new(station_list.size) {[]}
      day_estimate_table_departures = Array.new(station_list.size) {[]}

      # nr de curse
      nr_of_courses = start_times_table.size
      nr_of_courses.times do |index_course|

        # Luam pozitiile statiilor in care nu circula cursa (exceptate)
        excepted_station_indexes = []
        self.times_table[day_kind_name][1].each do |key, value|
          if value[index_course].downcase.to_s == "x"
            excepted_station_indexes << key
          end
        end

        # Luam pozitiile statiilor speciale
        special_station_indexes = self.special_station_indexes(Time.zone.today, index_course)
        # Le populam cu orele fixe din baza de date
        index = 0
        self.times_table[day_kind_name][1].each do |key, value|
          if !excepted_station_indexes.include?(key) and !value[index_course].blank? # daca avem ora fixa in aceasta statie pe aceasta cursa
            if value[index_course]["-"]
              # Daca avem in orar "timp_sosire - timp_plecare", avem ambele momente prestabilite
              day_estimate_table_arrivals[special_station_indexes[index]]   << value[index_course].split("-")[0]
              day_estimate_table_departures[special_station_indexes[index]] << value[index_course].split("-")[1]
            else
              # Avem doar timpii de sosire in statie, cei de plecare ii facem identici
              day_estimate_table_arrivals[special_station_indexes[index]]   << value[index_course]
              day_estimate_table_departures[special_station_indexes[index]] << value[index_course]
            end

            index += 1
          end
        end

        # Pornim de la statiile care au deja orarul cunoscut (cele speciale)
        special_station_indexes.each_with_index do |index_special_station, i|
          # Pentru ultima statie nu avem si pe "urmatoarea"
          if index_special_station != special_station_indexes[-1]
            station_start_index = index_special_station
            station_end_index   = special_station_indexes[i+1]
            # identificam statiile intermediare
            intermediary_station_indexes = (station_start_index..station_end_index).to_a
            # eliminam din statiile intermediare pe cele exceptate!
            intermediary_station_indexes -= excepted_station_indexes
            # Obtinem momentele estimate pentru statiile intermediare
            # pornind de la PLECAREA din statia 1 pana la SOSIREA in statia 2
            new_moments = Moment.split(day_estimate_table_departures[station_start_index][index_course], day_estimate_table_arrivals[station_end_index][index_course], intermediary_station_indexes.count)
            # Le introducem in Hash, fara capetele Array-ului cu momentele noi
            # puts "Index cursa: #{index_course}, Statii intermediare: #{intermediary_station_indexes}"
            intermediary_station_indexes[1..-2].each_with_index do |index_station, j|
              day_estimate_table_arrivals[index_station]   << new_moments[j]
              day_estimate_table_departures[index_station] << new_moments[j]
            end
          end
        end

        # In final, adaugam valori "X" la statiile exceptate
        excepted_station_indexes.each do |index_station|
          day_estimate_table_arrivals[index_station][index_course]   = "X"
          day_estimate_table_departures[index_station][index_course] = "X"
        end
      end

      return [day_estimate_table_arrivals, day_estimate_table_departures]
    else
      # Autobuzul nu circula in aceasta zi
      return nil
    end
  end

  # Indexurile liniilor speciale dintr-o zi - pe o anumita cursa!
  def special_station_indexes(day, index_course)
    if circulates_at? day
      day_kind_id = SpecialDay.kind_id_of(day)
      day_kind_name = SpecialDay.new(kind_id: day_kind_id).kind_name.to_s
      indexes = []
      
      self.times_table[day_kind_name][1].each do |key, value|
        # pentru cazurile cand avem ore la o anumita statie
        # verificam sa avem si pe cursa curenta!
        # E posibil sa avem ore stabilite fixe doar pentru anumite curse ale liniei
        if !value[index_course].blank? and value[index_course].downcase != "x"
          # exista ora prestabilita pentru aceasta cursa, deci o luam
          indexes << key
        end
      end
      indexes
    end
  end
end
