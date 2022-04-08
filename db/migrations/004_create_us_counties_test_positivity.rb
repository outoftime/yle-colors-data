Sequel.migration do
  change do
    create_table(:us_counties_test_positivity) do
      primary_key :id
      column :date, :date, null: false
      column :state, :varchar, null: false
      column :county, :varchar, null: false
      column :test_positivity_rate, :float, null: false

      index [:state, :county, :date], unique: true
    end
  end
end
