class CreateLines < ActiveRecord::Migration[7.0]
  def change
    create_table :lines do |t|
      t.string :name
      t.text :station_list

      t.timestamps
    end
  end
end
