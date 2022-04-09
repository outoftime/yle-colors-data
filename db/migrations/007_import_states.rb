Sequel.migration do
  up do
    require "csv"
    require "active_support/all"
    CSV.open(File.join(File.dirname(__FILE__), "..", "..", "state-abbreviations.csv"), headers: %w[name abbreviation]) do |csv|
      rows = csv.map do |row|
        name = row["name"]
        {name:, abbreviation: row["abbreviation"], slug: name.parameterize}
      end

      from(:states).multi_insert(rows)
    end
  end

  down do
    from(:states).truncate
  end
end
