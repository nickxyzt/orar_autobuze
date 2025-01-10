class SiteController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    unless session[:line_id]
      @current_line = Line.first
    else
      @current_line = Line.find(session[:line_id])
    end
    @current_stations = @current_line.stations

    # ultimele confirmari pentru aceasta linie
    # luam in medie ultimele 10 valori pentru fiecare statie
    stops = Stop.where(line_id: @current_line.id).
      order('created_at DESC').
      limit(@current_stations.size * 10 * @current_line.start_times.size).
      map {|stop| Moment.new(stop.created_at.strftime("%H:%M"))}

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
      @current_line.start_times.each_with_index do |time_start, index_cursa|
        # creare vector cu 3 elemente
        start_t = Moment.new(@current_line.start_times[index_cursa])
        end_t   = Moment.new(@current_line.end_times[index_cursa]) 
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

        # identificam inregistrarile pe aceasta linie care sunt in jurul momentului
        # folosim campul time_threshold
        matched_stops = stops.select{|stop| (stop.time - moment_estimat.time).abs <= @current_line.time_threshold}.
          map {|moment| moment.time}
        moment_mediu = nil
        if matched_stops.size > 0
          moment_mediu = Moment.new(matched_stops.sum / matched_stops.size).to_s
        end

        # ultimul moment confirmat al acestei curse
        moment_confirmat = media

        station_data << [moment_estimat.to_s, moment_mediu.to_s, moment_confirmat]
      end
      @schedule << station_data
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
