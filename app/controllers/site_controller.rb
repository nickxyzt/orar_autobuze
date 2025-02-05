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
    unless session[:line_id]
      @current_line = Line.first
    else
      @current_line = Line.find(session[:line_id])
    end
    today_kind_id         = SpecialDay.kind_id_of(Time.zone.today)
    today_kind_name       = SpecialDay.new(kind_id: today_kind_id).kind_name
    @today_kind_long_name = SpecialDay.new(kind_id: today_kind_id).kind_long_name

    # Daca circula in astfel de zile
    if @current_line.times_table[today_kind_name]
      @estimated_schedule   = @current_line.estimated_schedule(Time.zone.today)
      @courses_count        = @estimated_schedule.first[1].size
      @stations_ids         = @current_line.station_list
      # Reprezinta un Hash cu orele fixe din baza de date
      today_times_table = {}
      @current_line.times_table[today_kind_name][1].each do |key, value|
        # inlocuim cuvintele "start" si "end" cu id-urile statiilor
        case key
        when "start"
          key = @stations_ids[0]
        when "end"
          key = @stations_ids[-1]
        end
        today_times_table[key] = value
      end
      @special_stations_ids = today_times_table.keys
    else
      @error_message = "Linia #{@current_line.name} nu circulă în această zi!"
    end
  end

  # userul schimba linia pentru care vede orarul
  def change_current_line
    session[:line_id] = params[:line_id]
    redirect_to site_line_schedule_url
  end

  # userul schimba statia pentru care vede orarul

  def confirm_stop
    new_stop = Stop.new(station_id: params[:modal_station_id], line_id: params[:modal_line_id], session_id: request.session.id)
    new_stop.save
    redirect_to site_line_schedule_url, notice: "Mulțumim pentru implicarea ta în comunitate!|success"
  end

end
