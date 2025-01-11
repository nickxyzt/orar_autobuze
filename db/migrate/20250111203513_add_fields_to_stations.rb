class AddFieldsToStations < ActiveRecord::Migration[7.0]
  def change
    add_column :stations, :master_station_id, :integer
    add_column :stations, :display_name, :string
  end
end
