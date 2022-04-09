Sequel.migration do
  change do
    create_table(:covid_act_now_county_data) do
      primary_key :id
      column :date, :date, null: false
      column :state, :varchar, null: false
      column :county, :varchar, null: false
      column :weekly_new_cases_per_100k, :float
      column :test_positivity_ratio, :float
      column :vaccinations_completed_ratio, :float

      index [:state, :county], unique: true
    end
  end
end
