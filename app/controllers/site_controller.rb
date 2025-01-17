class SiteController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Deocamdata definite aici
  # [PWA]
  REMINDER_TIMES = [10.minutes, 60.minutes, 1.days, 3.days, 7.days]

  # [PWA]
  def dismiss_button
    # Daca a apasat in trecut pe butoane din modaluri, refuzand instalarea
    if Time.zone.now >= session[:user_config_next_reminder]
      # Setam urmatorul reminder
      session[:user_config_next_reminder] = \
        Time.zone.now + REMINDER_TIMES[session[:user_config_next_reminder_index]]
      # Daca mai exista alti timpi in schema
      if session[:user_config_next_reminder_index] < REMINDER_TIMES.size - 1
        session[:user_config_next_reminder_index] += 1
      end
    end
  end

  def index
    # Pastram in sesiune daca a instalat PWA
    # [PWA]
    if params[:pwa_mode]
      session[:app_was_installed] = true
    end

    unless session[:line_id]
      @current_line = Line.first
    else
      @current_line = Line.find(session[:line_id])
    end
    @current_stations = @current_line.stations
    today_kind_id = SpecialDay.kind_id_of(Date.today)
    today_kind_name = SpecialDay.new(kind_id: today_kind_id).kind_name
    @today_kind_long_name = SpecialDay.new(kind_id: today_kind_id).kind_long_name

    # Daca circula in astfel de zile
    if @current_line.times_table[today_kind_name]
      # ultimele confirmari pentru aceasta linie
      # luam in medie ultimele 10 valori pentru fiecare statie
      stops = Stop.includes(:line).joins(:line).where(line_id: @current_line.id).
        where('stops.created_at >= lines.modified_at').
        order('stops.created_at DESC').
        limit(@current_stations.size * 10 * @current_line.times_table[today_kind_name][1][:start].size).
        map {|stop| [stop.station_id, Moment.new(stop.created_at.strftime("%H:%M"))]}

      # ultima confirmare venita de la user pentru linia curenta
      # (necesar pt a nu mai putea confirma statiile de dinaintea ei)
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

      # Cream o matrice care are pe fiecare rand (statie) un vector cu 3 elemente: 
      # 1. momentele estimative ale fiecarei statii
      # 2. momentele medii confirmate ale fiecarei statii
      # 3. ultimul moment confirmat al fiecarei statii
      @schedule = []
      @current_stations.each_with_index do |station, index_station|
        station_data = [] # adaugam un rand pentru statie
        # pentru fiecare cursa in parte, creare momente estimate
        @current_line.times_table[today_kind_name][1][:start].each_with_index do |time_start, index_cursa|
          # Etapa I - cream Array-urile cu:
          # - timpii estimati pe baza intregului traseu
          # - timpii raportati in trecut de utilizatori si soferi (cu distanta threshold fata de timpii estimati)
          # - timpii REALI raportati de soferi, sau in lipsa lor, de utilizatori
          start_t = Moment.new(@current_line.times_table[today_kind_name][1][:start][index_cursa])
          end_t   = Moment.new(@current_line.times_table[today_kind_name][1][:end][index_cursa])
          # durata intervalului unei curse intregi
          durata  = end_t.time - start_t.time
          # durata medie a unui interval
          media   = durata.to_f / (@current_stations.size - 1)

          # cat dureaza de la prima statie pana aici
          moment_estimat = Moment.new(start_t.time + (index_station * media).to_i)
          # momentul de final il preluam, sa nu apara rotunjiri
          if index_station == @current_stations.size - 1
            moment_estimat = end_t
          end

          # Etapa II - corectam Array-ul timpilor estimati, pe baza:
          # - matricii timpilor REALI, daca exista
          # - matricii timpilor raportati (in trecut deci)

          # identificam inregistrarile pe aceasta linie care sunt in jurul momentului
          # folosim campul time_threshold
          matched_stops = stops.select{|station_id, stop| station_id == station.id and (stop.time >= start_t.time - 2) and (stop.time - moment_estimat.time).abs <= @current_line.time_threshold}.
            map {|elem| elem[1].time}
          moment_mediu = nil
          if matched_stops.size > 0
            moment_mediu = Moment.new(matched_stops.sum / matched_stops.size).to_s
          end

          # ultimul moment confirmat al acestei curse
          moment_confirmat = media

          # creare vector cu 3 elemente
          station_data << [moment_estimat.to_s, moment_mediu.to_s, moment_confirmat]
        end
        @schedule << station_data
      end
    else
      @error_message = "Autobuzul #{@current_line.name} nu circulă în această zi!"
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
