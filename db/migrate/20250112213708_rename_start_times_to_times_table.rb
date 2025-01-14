class RenameStartTimesToTimesTable < ActiveRecord::Migration[7.0]
  def change
    rename_column :lines, :start_times, :times_table
    remove_column :lines, :end_times
  end
end
