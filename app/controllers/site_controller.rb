class SiteController < ApplicationController
  def index
    unless session[:line_id]
      @current_line = Line.first
    else
      @current_line = Line.find(session[:line_id])
    end
    @current_stations = @current_line.station_list.map {|station_id| Station.find(station_id)}

    # ultima confirmare venita de la user pentru linia curenta
    latest_user_confirmation = @current_line.stops.
      where(session_id: session[:session_id]).
      where(line_id: session[:line_id]).
      where('created_at > ?', Time.zone.now - 15.minutes).
      order('created_at').last
    if latest_user_confirmation
      # ultima statie confirmata
      station = Station.find latest_user_confirmation.station_id
      @last_station_confirmed_index = @current_stations.index(station)
    end

    # Calculare intervale si obtinere array-uri cu datele
    @res = [] # un Array cu rezultatele pentru fiecare statie din lista
    @current_stations.each_with_index do |station, station_index|
      @res[station_index] = [] # Vom avea un Array cu informatii relevante pentru fiecare statie
      stops = Stop.where(station_id: station.id).where(line_id: @current_line.id).
        order('created_at DESC').limit(500)
      # ar trebui ca cele din ultimele zile sa fie mai importante 
      # decat cele din trecut, chiar daca sunt mai putine...

      # Transformam totul doar in minute si sortam
      stops = stops.map {|stop| hour = stop.created_at.hour; min = stop.created_at.min; hour*60 + min}

      # Adaugam si orele de start si de final conform graficului, ca si cum ar fi stopuri initiale
      # (doar pentru prima statie, evident!)
      if station_index == 0
        ore_de_start = @current_line.start_times.map do |time| 
          time = time.split(":").map(&:to_i)
          time[0]*60 + time[1]
        end
        stops += ore_de_start
      end
      if station_index == @current_stations.size - 1
        ore_de_final = @current_line.end_times.map do |time| 
          time = time.split(":").map(&:to_i)
          time[0]*60 + time[1]
        end
        stops += ore_de_final
      end
      sorted_stops = stops.sort

      # luam momentul in care linia a sosit in statie in intervalul care incepe la ora hour_start
      # (luam o marja)
      @current_line.start_times.each_with_index do |start_time, line_index|
        hour, minute = start_time.split(':').map(&:to_i)
        moment_start = hour * 60 + minute

        # ajustare moment_start cu valoarea medie a unei statii precedente, daca exista
        # (pentru a cauta intr-un interval mai probabil)
        prev_station_index = nil
        if station_index > 0
          station_index.downto(1) do |i|
            # DOAR daca statia gasita NU este repetarea acestei statii!
            if @current_line.station_list[i] != @current_line.station_list[station_index] and @res[i][line_index]
              prev_station_index = i
              break;
            end
          end
        end
        if prev_station_index
          moment_start = @res[prev_station_index][line_index]
        end

        # calculare intervalul de "moment_start" 
        # (in functie de lungimea maxima a liniei)
        interval = moment_start..(moment_start+@current_line.max_time_length - 1)

        # opririle pentru acest "moment"
        this_moment_stops = sorted_stops.select {|elem| interval.include? elem}
        media = nil # valoarea default
        if this_moment_stops.size > 0
          # obtinerea valorii mediane (timpul mediu)
          if this_moment_stops.size.odd?
            median = this_moment_stops[this_moment_stops.length/2]
          else
            median = (this_moment_stops[this_moment_stops.size / 2 - 1] + this_moment_stops[this_moment_stops.size / 2]) / 2
          end

          # luam din sorted_stops valorile de +-15 minute fata de median, si la acestea calculam media
          selected = sorted_stops.select {|elem| (median-15..median+14).include? elem}
          # avem grija sa luam doar pe cele mai mari decat media intervalului precedent
          if @res[station_index][-1]
            selected = selected.select {|elem| elem > @res[station_index][-1]}
          end

          if selected.size > 0
            media = selected.sum / selected.length
          end
        end
        # valoarea de afisat in tabel pentru momentul de start
        # pentru statia station_id
        @res[station_index] << media 
      end

    end
  end

  def change_current_line
    session[:line_id] = params[:line_id]
    redirect_to site_index_url
  end

  def confirm_stop
    new_stop = Stop.new(station_id: params[:modal_station_id], line_id: params[:modal_line_id], session_id: request.session.id)
    new_stop.save
    redirect_to site_index_url, notice: "Mulțumim pentru implicarea ta în comunitate!|success"
  end

end
