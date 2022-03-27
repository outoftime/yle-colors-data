Sequel.migration do
  up do
    alter_table(:us_counties_rolling_averages) do
      set_column_type :cases_avg_per_100k, :numeric
    end
  end

  down do
    alter_table(:us_counties_rolling_averages) do
      set_column_type :cases_avg_per_100k, :integer
    end
  end
end
