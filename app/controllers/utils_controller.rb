require "ferrum"
require 'nokogiri'

class UtilsController < ApplicationController

  # Obtinere orar de pe site-ul oficial, 
  # folosind in link-ul web denumrile statiilor de plecare si de sosire
  def get_schedule
    @obtained_schedule = {} # orarul liniei

    if request.post?
      @line_id = params[:line_id] # pentru a ramane selectata in form
      line = Line.find(@line_id)
      line_name = line.name.split(" ")[0] # eliminam orice apare
      url_base = "https://www.sptl.ro/live/"

      ["wd", "we"].each do |dd|
        if dd == "wd"
          day_kind = "working"
          days = [1,2,3,4,5]
        else
          day_kind = "holiday"
          days = [0,6]
        end
        @obtained_schedule[day_kind] = [days, {}]

        special_station_indexes = line.special_station_indexes(Date.today, :all)
        special_station_indexes.each_with_index do |station_index, index|
          # Avem nevoie de o pereche, deci nu repetam bucla pentru ultima statie
          if index < special_station_indexes.length - 1
            this_special_station_index  = special_station_indexes[index]
            this_special_station_id     = line.station_list[special_station_indexes[index]]
            this_special_station        = Station.find(this_special_station_id)
            next_special_station_index  = special_station_indexes[index+1]
            next_special_station_id     = line.station_list[special_station_indexes[index+1]]
            next_special_station        = Station.find(next_special_station_id)

            # construim url-ul
            url = "#{url_base}?statie=#{this_special_station.short_name}&la=#{next_special_station.short_name}&zi=#{dd}"
            browser = Ferrum::Browser.new
            browser.go_to(url)
            browser.at_css("body") # așteaptă DOM-ul
            sleep 2 # dacă pagina mai generează conținut prin JS
            html = browser.body
            browser.quit

            doc = Nokogiri::HTML(html)

            departures = []
            arrivals   = []

            # Luam fiecare timp de "departure" si verificam daca este pentru linia dorita
            doc.css('span.lv-s2s-dep').each do |span|
              parent = span.parent.parent
              found_line = parent.at_xpath('./*[@class="lv-s2s-line"]').text
              if found_line == line_name
                departures << span.text
              end
            end
            # A doua varianta posibila (ex: dec_1 catre piata_garii)
            doc.css('span.lv-lo-dep').each do |span|
              parent = span.parent.parent.parent
              found_line = parent.at_xpath('./*[@class="lv-s2s-line"]').text
              if found_line == line_name
                departures << span.text
              end
            end

            # Similar pentru "arrival"
            doc.css('span.lv-s2s-arr').each do |span|
              parent = span.parent.parent
              found_line = parent.at_xpath('./*[@class="lv-s2s-line"]').text
              if found_line == line_name
                arrivals << span.text
              end
            end
            # A doua varianta posibila (ex: dec_1 catre piata_garii)
            doc.css('span.lv-lo-arr').each do |span|
              parent = span.parent.parent.parent
              found_line = parent.at_xpath('./*[@class="lv-s2s-line"]').text
              if found_line == line_name
                sibling = span.previous_element
                if sibling.text == "Ajunge"
                  arrivals << span.text
                end
              end
            end

            # Am obtinut un orar pentru un tip de zi pentru linia dorita
            # Facem merge
            # La plecari, daca exista deja sosirile in statie, le adaugam
            if !@obtained_schedule[day_kind][1][this_special_station_index].blank?
              departures.each_with_index do |departure, index|
                @obtained_schedule[day_kind][1][this_special_station_index][index] += "-#{departure}"
              end
            else
              @obtained_schedule[day_kind][1][this_special_station_index] = departures
            end
            # Sosirile le luam pur si simplu, daca vor exista plecari din statie vor fi intr-o bucla viitoare
            @obtained_schedule[day_kind][1][next_special_station_index] = arrivals
          end
        end
      end

      # Preluam orarul pentru zilele speciale
      @obtained_schedule["holiday_special"] = line.times_table["holiday_special"] || [nil, {}]

      # Verificare diferente
      @messages = []
      ["working", "holiday"].each do |day_kind|
        if @obtained_schedule[day_kind] != line.times_table[day_kind]
          @messages << "Difera orarul pentru #{day_kind}."
        end
      end
      @messages = @messages.join("  ")
      @messages = "Nu exista diferente!" if @messages.blank?
    end
  rescue => e
    flash.now[:notice] = "A aparut eroarea #{e} la obtinerea sau procesarea paginii."
    render :get_schedule
  end
end
