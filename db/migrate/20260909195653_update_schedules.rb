class UpdateSchedules < ActiveRecord::Migration[7.0]
  # Actualizare times_table in tabela Line (transformare "start" si "end")
  # (migratia este facuta pentru productie - acolo nu am acces direct la date)
  def up
    Line.find_each do |line|
      times_table = line.times_table
      next unless times_table.is_a?(Hash)

      station_count = line.station_list.length

      times_table.each_value do |value|
        next unless value.is_a?(Array) && value.length >= 2

        table = value[1]

        if table.is_a?(Hash)
          if table.key? "start"
            table[0] = table[11]
            table.delete("start")
          end
          if table.key? "end"
            table[station_count - 1] = table[11]
            table.delete("end")
          end
        end
      end

      line.update_column(:times_table, times_table)
    end
  end

  def down
  end

end
