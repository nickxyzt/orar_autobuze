class SiteController < ApplicationController
  helper_method :current_line

  def index
    # ultima confirmare venita de la user pentru linia curenta
    latest_user_confirmation = current_line.stops.
      where(session_id: session[:session_id]).
      where(line_id: session[:line_id]).
      where('created_at > ?', Time.now - 15.minutes).
      order('created_at').last
    if latest_user_confirmation
      # ultima statie confirmata
      station = Station.find latest_user_confirmation.station_id
      @last_station_confirmed_index = current_line.stations.index(station)
    end

    # Calculare intervale si obtinere array-uri cu datele
    @res = {} # un Hash cu rezultatele pentru linia curenta
    current_line.stations.each_with_index do |station, index|
      @res[station.id] = [] # Vom avea un Array cu informatii relevante pentru fiecare statie
      stops = Stop.where(station_id: station.id).where(line_id: current_line.id).
        order('created_at DESC').limit(500)
      # ar trebui ca cele din ultimele zile sa fie mai importante 
      # decat cele din trecut, chiar daca sunt mai putine...

      # Transformam totul doar in minute si sortam
      sorted_stops = stops.map {|stop| hour = stop.created_at.hour; min = stop.created_at.min; hour*60 + min}.sort

      # luam momentul in care linia a sosit in statie in intervalul care incepe la ora hour_start
      # (luam o marja)
      0.upto(23) do |moment_start| # folosim ore pentru inceputul momentului in care se face stopul
        # transformare moment_start in minute
        moment_start = moment_start * 60

        # ajustare moment_start cu valoarea medie a statiei precedente, daca exista
        # (pentru a cauta intr-un interval mai probabil)
        if current_line.stations[index-1] and @res[current_line.stations[index-1]]
          moment_start = @res[current_line.stations[index-1]]
        end
        # calculare intervalul de "moment_start" 
        # (in functie de lungimea maxima a liniei)
        interval = moment_start..(moment_start+current_line.max_time_length - 1)

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
          if @res[station.id][-1]
            selected = selected.select {|elem| elem > @res[station.id][-1]}
          end

          if selected.size > 0
            media = selected.sum / selected.length
          end
        end
        # valoarea de afisat in tabel pentru momentul de start
        # pentru statia station_id
        @res[station.id] << media 
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
    redirect_to site_index_url, notice: "Mulțumim implicarea ta în comunitate!|success"
  end

  private
  def current_line
    if session[:line_id]
      Line.find session[:line_id]
    else
      raise 'NoLine'
    end
  rescue
    Line.first
  end
end
