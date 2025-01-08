class Stop < ActiveRecord
  belongs_to :line
  belongs_to :station
end
