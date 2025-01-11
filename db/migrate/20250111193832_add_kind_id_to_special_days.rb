class AddKindIdToSpecialDays < ActiveRecord::Migration[7.0]
  def change
    add_column :special_days, :kind_id, :integer, default: 1
  end
end
