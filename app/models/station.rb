class Station < ApplicationRecord
  validates_uniqueness_of :name

  has_many :stops
end
