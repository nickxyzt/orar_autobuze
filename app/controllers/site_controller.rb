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
  end

  def line_schedule
    begin
      session[:line_id]   = params[:id] if params[:id]
      session[:line_id] ||= Line.first.id
      @current_line       = Line.find(session[:line_id])
    rescue
      # Daca intre timp stergem linia din BD
      session[:line_id] = Line.first.id
      @current_line     = Line.find(session[:line_id])
    end
    @estimated_schedule   = @current_line.estimated_schedule(Time.zone.today)

    # Daca circula in astfel de zile
    if @estimated_schedule
      today_kind_id             = SpecialDay.kind_id_of(Time.zone.today)
      today_kind_name           = SpecialDay.new(kind_id: today_kind_id).kind_name
      @today_kind_long_name     = SpecialDay.new(kind_id: today_kind_id).kind_long_name
      @courses_count            = @estimated_schedule.first.size
      @special_station_indexes  = @current_line.special_station_indexes(Time.zone.today)
    else
      @error_message = "Linia #{@current_line.name} nu circulă în această zi!"
    end
  end

  # userul schimba linia pentru care vede orarul
  def change_current_line
    session[:line_id] = params[:line_id]
    redirect_to site_line_schedule_url
  end

  # orarul pe o anumita statie
  def station_schedule
    begin
      session[:station_id]   = params[:id] if params[:id]
      session[:station_id] ||= Station.first.id
      @current_station       = Station.find(session[:station_id])
    rescue
      # Daca intre timp stergem linia din BD
      session[:station_id] = Station.first.id
      @current_station     = Station.find(session[:station_id])
    end

    @related_stations     = Station.where(master_station_id: @current_station.master_station_id)
    today_kind_id         = SpecialDay.kind_id_of(Time.zone.today)
    today_kind_name       = SpecialDay.new(kind_id: today_kind_id).kind_name
    @today_kind_long_name = SpecialDay.new(kind_id: today_kind_id).kind_long_name

    # Array cu elemente [stop_time, line_id], exemplu: [["08:00", 5], ["09:00", 5], ["09:10", 6] ...]
    @estimated_schedule = []
    Line.all.each do |line| 
      station_list    = line.station_list
      # Indexurile statiei in aceasta linie
      station_indexes = station_list.each_index.select {|index| station_list[index] == @current_station.id}
      line_schedule   = line.estimated_schedule(Time.zone.today)
      # Doar daca linia circula in aceasta zi!
      if line_schedule
        courses_count   = line_schedule[0].size
        # Luam toate aparitiile statiei in fiecare cursa
        courses_count.times do |index_course|
          station_indexes.each do |index_station|
            @estimated_schedule << [ line_schedule[index_station][index_course], line.id]
          end
        end
      end
    end
    @estimated_schedule.sort_by! do |elem| Moment.new(elem[0]).time end
  end

  # userul schimba statia pentru care vede orarul
  def change_current_station
    session[:station_id] = params[:station_id]
    redirect_to site_station_schedule_url
  end

  def confirm_stop
    new_stop = Stop.new(station_id: params[:modal_station_id], line_id: params[:modal_line_id], session_id: request.session.id)
    new_stop.save
    redirect_to site_line_schedule_url, notice: "Mulțumim pentru implicarea ta în comunitate!|success"
  end

end
