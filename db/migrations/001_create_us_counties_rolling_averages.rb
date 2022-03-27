Sequel.migration do
  change do
    create_table(:us_counties_rolling_averages) do
      primary_key :id
      column :import_id, :uuid, null: false
      column :date, :date, null: false
      column :state, :varchar, null: false
      column :county, :varchar, null: false
      column :cases_avg_per_100k, :integer, null: false

      index [:import_id, :state, :county, :date], unique: true
    end
  end
end