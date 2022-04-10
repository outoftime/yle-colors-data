Sequel.migration do
  up do
    require "active_support/all"

    alter_table(:covid_act_now_county_data) do
      add_column :county_slug, :varchar
    end

    current_rows = from(:covid_act_now_county_data).select(:id, :county).to_a
    current_rows.each do |row|
      from(:covid_act_now_county_data).where(id: row[:id]).update(county_slug: row[:county].parameterize)
    end

    alter_table(:covid_act_now_county_data) do
      set_column_not_null :county_slug
      add_index [:state, :county_slug], unique: true
    end
  end
end
