class SpecialDay < ApplicationRecord
  validates_uniqueness_of :day

  # Tipurile de zile, stabilite de conducere si legal
  # working = zi in care se recupereaza, chiar daca este sarbatoare
  # holiday = weekend + sarbatori legale
  # holiday_special = zile speciale cu program diferit (prima zi de Craciun etc)
  # not_working = zi nelucratoare
  KINDS = {working: 1, holiday: 2, holiday_special: 3, not_working: 4}
  KINDS_LONG_NAMES = {"zi lucrătoare" => 1, "weekend și sărbători legale" => 2, "zi specială de sărbători" => 3, "zi nelucrătoare" => 4}

  def kind_name
    KINDS.invert[kind_id]
  end

  def kind_long_name
    KINDS_LONG_NAMES.invert[kind_id]
  end

  # Tipul unei zile
  def self.kind_id_of(day)
    found_day = ApplicationController.special_days.find {|elem| elem.day == day}
    if found_day
      found_day.kind_id
    else
      # Stabilirea zilelor lucratoare si weekend-uri, asa cum este in legislatia din Romania
      if (1..5).include? day.wday 
        1 # :working
      else # 0 si 6 sunt Duminica si Sambata
        2 # :holiday - weekend are acelasi tratament cu sarbatorile legale
      end
    end
  end

end
