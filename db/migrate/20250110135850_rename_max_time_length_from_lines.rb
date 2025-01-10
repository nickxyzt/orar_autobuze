class RenameMaxTimeLengthFromLines < ActiveRecord::Migration[7.0]
  def change
    rename_column :lines, :max_time_length, :time_threshold
    change_column_default :lines, :time_threshold, 10
  end
end
