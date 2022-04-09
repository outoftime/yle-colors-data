require "csv"
require "net/http"
require "securerandom"
require "uri"

require "./db"

class NewYorkTimesImport
  IMPORT_URI = URI.parse("https://raw.githubusercontent.com/nytimes/covid-19-data/master/rolling-averages/us-counties-recent.csv")

  def initialize
    @import_id = SecureRandom.uuid
  end

  def start
    each_csv_row
      .lazy
      .select { |row| Date.parse(row["date"]) == latest_date }
      .each_slice(1000) do |rows|
      import_rows(rows)
    end
    update_import_id
    clean_up_imports
  end

  private

  attr_reader :import_id, :us_counties_rolling_averages, :import_ids

  def import_rows(rows)
    insert_rows = rows.map do |row|
      date = Date.parse(row["date"])
      county = row["county"]
      state = row["state"]
      cases_avg_per_100k = row["cases_avg_per_100k"].to_f

      {
        import_id:,
        date:,
        county:,
        state:,
        cases_avg_per_100k:
      }
    end
    DB[:us_counties_rolling_averages].multi_insert(insert_rows)
  end

  def update_import_id
    DB[:current_imports].insert_conflict(
      constraint: "current_imports_table_key",
      update: {import_id:},
      update_where: {
        Sequel[:current_imports][:table] => "us_counties_rolling_averages"
      }
    ).insert(
      table: "us_counties_rolling_averages",
      import_id:
    )
  end

  def clean_up_imports
    DB[:us_counties_rolling_averages]
      .exclude(import_id:)
      .delete
  end

  def each_csv_row(&block)
    response = Net::HTTP.get(IMPORT_URI)
    CSV.new(response, headers: true).each(&block)
  end

  def latest_date
    @latest_date ||= each_csv_row.lazy.map { |row| Date.parse(row["date"]) }.max
  end
end
