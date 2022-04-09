require "net/http"
require "uri"
require "yajl"

require "./db"

class CovidActNowImport
  IMPORT_URI = URI.parse("https://api.covidactnow.org/v2/counties.json?apiKey=#{ENV["COVID_ACT_NOW_API_KEY"]}")

  def start
    DB.transaction do
      table.truncate
      each_row.each_slice(1000) { |slice| import_rows(slice) }
    end
  end

  private

  def import_rows(rows)
    insert_rows = rows.map do |row|
      metrics = row[:metrics]
      {
        date: Date.parse(row.fetch(:lastUpdatedDate)),
        state: row.fetch(:state),
        county: row.fetch(:county),
        test_positivity_ratio: metrics.fetch(:testPositivityRatio),
        weekly_new_cases_per_100k: metrics.fetch(:weeklyNewCasesPer100k),
        vaccinations_completed_ratio: metrics.fetch(:vaccinationsCompletedRatio)

      }
    end
    table.multi_insert(insert_rows)
  end

  def each_row(&block)
    response = Net::HTTP.get(IMPORT_URI)
    Yajl::Parser.parse(response, symbolize_keys: true).each(&block)
  end

  def table
    DB[:covid_act_now_county_data]
  end
end
