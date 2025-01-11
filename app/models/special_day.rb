class SpecialDay < ApplicationRecord
  validates_uniqueness_of :day

  # Tipurile de zile, stabilite de conducere
  # holiday = weekend + sarbatori legale
  # recovery = zi in care se recupereaza, chiar daca este sarbatoare
  # holiday_special = zile speciale cu program diferit (prima zi de Craciun etc)
  # not_working = zi nelucratoare
  KINDS = {holiday: 1, recovery: 2, holiday_special: 3, not_working: 4}

  def kind_name
    KINDS.invert[kind_id]
  end
end
