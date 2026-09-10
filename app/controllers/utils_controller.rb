require "ferrum"
require 'nokogiri'

class UtilsController < ApplicationController

  # Obtinere orar de pe site-ul oficial, 
  # folosind in link-ul web denumrile statiilor de plecare si de sosire
  def get_schedule
    if request.post?
      # Avem de luat 2 pagini: pentru "working" si "holiday"
      # Intai eliminam parametrul pentru tipul de zi primit
      params["input_link"] = params["input_link"].sub("&zi=we", "")
      params["input_link"] = params["input_link"].sub("&zi=wd", "")

      @obtained_schedule = {}
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
        
        departures = []
        arrivals   = []

        doc.css('span.lv-s2s-dep').each do |span|
          departures << span.text
        end

        doc.css('span.lv-s2s-arr').each do |span|
          arrivals << span.text
        end

        @obtained_schedule[day_kind] = [days, {0 => departures, "last" => arrivals}]
      end
    end
  rescue
    redirect_to utils_get_schedule_url, notice: 'A aparut o eroare la obtinerea sau procesarea paginii.'
  end
end
