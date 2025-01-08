class Station < ApplicationRecord
  validates_uniqueness_of :name
end
