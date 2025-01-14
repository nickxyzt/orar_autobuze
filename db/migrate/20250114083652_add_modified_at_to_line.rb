class AddModifiedAtToLine < ActiveRecord::Migration[7.0]
  def change
    add_column :lines, :modified_at, :date
  end
end
