class Moment
  attr_accessor :time # durata in minute fata de miezul noptii

  # Initializare pe baza unui string de tipul "08:35"
  # sau pe baza unui integer de tipul 625
  def initialize(str = nil)
    if str
      # pentru cazul integer
      if str.to_i.to_s == str.to_s.strip
        @time = str.to_i
      else
        hour, min = str.split(':').map(&:to_i)
        @time = hour * 60 + min
      end
    else
      mom = Moment.new Time.zone.now.strftime("%H:%M")
      @time = mom.time
    end
  end

  def hour
    time / 60
  end

  def min
    time % 60
  end

  def to_s
    ("%02d" % hour) + (":%02d" % min)
  end

  def to_time
    Time.zone.parse("#{Time.zone.today.to_s} #{self.to_s}")
  end

  # Impartire timpi INTRE start si stop, pe un numar de statii
  # (start si stop se EXCLUD!)
  # start_time, end_time sunt STRING-uri
  # station_count = numarul TOTAL de statii, inclusiv pornire si oprire
  def self.split(start_time, end_time, station_count)
    start_t = Moment.new(start_time)
    end_t   = Moment.new(end_time)
    # durata intregului interval, intre start si stop
    durata  = end_t.time - start_t.time
    # durata medie a unui interval
    media   = durata.to_f / (station_count - 1)
    rv = [start_time]
    (station_count-1).times do |index|
      rv << Moment.new((start_t.time + media*(index+1)).to_i).to_s
    end
    rv[1..-2]
  end
end
