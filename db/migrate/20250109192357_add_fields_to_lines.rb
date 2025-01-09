class AddFieldsToLines < ActiveRecord::Migration[7.0]
  def change
    add_column :lines, :max_time_length, :integer, default: 30
    add_column :lines, :start_times, :text
    add_column :lines, :end_times, :text
  end
end
