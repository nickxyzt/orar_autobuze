class Station < ApplicationRecord
  validates_uniqueness_of :name
  validates_presence_of :name, :display_name

  belongs_to :master_station, class_name: 'Station', optional: true
  has_many :substations, class_name: 'Station', foreign_key: 'master_station_id'
  has_many :stops

end
