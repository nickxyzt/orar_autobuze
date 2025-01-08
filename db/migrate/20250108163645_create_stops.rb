class CreateStops < ActiveRecord::Migration[7.0]
  def change
    create_table :stops do |t|
      t.integer :station_id
      t.integer :line_id
      t.string :session_id

      t.timestamps
    end
  end
end
