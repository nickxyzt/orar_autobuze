class AddHtmlColorToLine < ActiveRecord::Migration[7.0]
  def change
    add_column :lines, :html_color, :string, default: "#ccc"
  end
end
