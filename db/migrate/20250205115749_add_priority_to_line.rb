class AddPriorityToLine < ActiveRecord::Migration[7.0]
  def change
    add_column :lines, :priority, :integer, default: 0
  end
end
