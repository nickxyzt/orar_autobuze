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
end
