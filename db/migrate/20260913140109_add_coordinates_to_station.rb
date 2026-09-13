class AddCoordinatesToStation < ActiveRecord::Migration[7.0]
  def change
    add_column :stations, :short_name, :string
    add_column :stations, :latitude,  :decimal, precision: 10, scale: 7
    add_column :stations, :longitude, :decimal, precision: 10, scale: 7
  end
end
