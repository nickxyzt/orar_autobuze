class AddDescriptionToLine < ActiveRecord::Migration[7.0]
  def change
    add_column :lines, :description, :string
  end
end
