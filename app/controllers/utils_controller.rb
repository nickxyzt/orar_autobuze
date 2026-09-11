require "ferrum"
require 'nokogiri'

class UtilsController < ApplicationController

  # Obtinere orar de pe site-ul oficial, 
  # folosind in link-ul web denumrile statiilor de plecare si de sosire
  def get_schedule
    @obtained_schedules = {} # putem avea mai multe linii

    if request.post?
      # Avem de luat 2 pagini: pentru "working" si "holiday"
      # Intai eliminam parametrul pentru tipul de zi primit
      params["input_link"] = params["input_link"].sub("&zi=we", "")
      params["input_link"] = params["input_link"].sub("&zi=wd", "")

      ["wd", "we"].each do |dd|
        if dd == "wd"
          day_kind = "working"
          days = [1,2,3,4,5]
        else
          day_kind = "holiday"
          days = [0,6]
        end

        browser = Ferrum::Browser.new
        link = params["input_link"] + "&zi=#{dd}"
        browser.go_to(link)
        browser.at_css("body") # așteaptă DOM-ul
        sleep 2 # dacă pagina mai generează conținut prin JS
        html = browser.body
        browser.quit

        doc = Nokogiri::HTML(html)
        
        # Luam fiecare linie in parte (pe ruta aleasa) si construim orarul
        lines = []
        doc.css('span.lv-s2s-line').each do |span|
          lines << span.text
        end
        lines = lines.uniq

        lines.each do |line|
          @obtained_schedules[line] = {} if @obtained_schedules[line].blank?
          departures = []
          arrivals   = []

          doc.css('span.lv-s2s-dep').each do |span|
            parent = span.parent.parent
            found_line = parent.at_xpath('./*[@class="lv-s2s-line"]').text
            if found_line == line
              departures << span.text
            end
          end

          doc.css('span.lv-s2s-arr').each do |span|
            parent = span.parent.parent
            found_line = parent.at_xpath('./*[@class="lv-s2s-line"]').text
            if found_line == line
              arrivals << span.text
            end
          end

          # Am obtinut un orar pentru un tip de zi pentru o anumita linie
          obtained_schedule = [days, {0 => departures, "last" => arrivals}]
          # Il adaugam in lista
          @obtained_schedules[line][day_kind] = obtained_schedule
        end
      end
    end
  rescue
    redirect_to utils_get_schedule_url, notice: 'A aparut o eroare la obtinerea sau procesarea paginii.'
  end
end
