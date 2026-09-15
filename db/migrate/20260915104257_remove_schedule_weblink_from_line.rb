class RemoveScheduleWeblinkFromLine < ActiveRecord::Migration[7.0]
  def change
    remove_column :lines, :schedule_weblink
  end
end
