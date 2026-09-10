class AddScheduleWeblinkToLine < ActiveRecord::Migration[7.0]
  def change
    add_column :lines, :schedule_weblink, :text
  end
end
