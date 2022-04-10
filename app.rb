require "sinatra/base"
require "sinatra/json"
require "sinatra/reloader"

require "./environment"
require "./db"

class YleColorsData < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  before do
    headers "Access-Control-Allow-Origin" => "*",
      "Cache-Control" => "public, s-max-age=900"
  end

  get "/states" do
    json(
      current_rolling_averages
      .distinct
      .select(:state)
      .map { |row| row[:state] }
      .sort
    )
  end

  get "/states/:state/counties" do |state|
    json(
      current_rolling_averages
        .where(state:)
        .distinct
        .select(:county)
        .map { |row| row[:county] }
        .sort
    )
  end

  get "/states/:state/counties/:county/7_day_cases_per_100k" do |state, county|
    row = current_rolling_averages
      .where(state:)
      .where(county:)
      .order(Sequel.desc(:date))
      .select(:cases_avg_per_100k, :date)
      .first

    fail Sinatra::NotFound if row.nil?

    json(
      "7_day_cases_per_100k": (row[:cases_avg_per_100k] * 7).round,
      date: row[:date].to_s
    )
  end

  get "/country/us/states" do
    json({states:
      states
      .select(:slug, :name)
      .map { |row| {slug: row.fetch(:slug), name: row.fetch(:name)} }
      .sort_by { |state| state.fetch(:name) }})
  end

  get "/country/us/states/:state_slug/counties" do |slug|
    state = states.select(:name, :abbreviation).where(slug:).first
    json({
      state: {name: state.fetch(:name)},
      counties: covid_act_now_county_data
      .where(state: state.fetch(:abbreviation))
      .select(:county, :county_slug)
      .map { |row| {name: row.fetch(:county), slug: row.fetch(:county_slug)} }
    })
  end

  get "/country/us/states/:state_slug/counties/:county_slug/metrics" do |state_slug, county_slug|
    state = states.select(:name, :abbreviation).where(slug: state_slug).first
    county_data = covid_act_now_county_data
      .select(:date, :county, :weekly_new_cases_per_100k, :test_positivity_ratio, :vaccinations_completed_ratio)
      .where(state: state.fetch(:abbreviation), county_slug:)
      .first

    json({
      state: {name: state.fetch(:name)},
      county: {name: county_data.fetch(:county)},
      metrics: county_data.slice(
        :date,
        :weekly_new_cases_per_100k,
        :test_positivity_ratio,
        :vaccinations_completed_ratio
      )
    })
  end

  private

  def current_rolling_averages
    DB[:us_counties_rolling_averages].where(
      import_id: current_import_id
    )
  end

  def covid_act_now_county_data
    DB[:covid_act_now_county_data]
  end

  def states
    DB[:states]
  end

  def current_import_id
    DB[:current_imports]
      .where(table: "us_counties_rolling_averages")
      .select(:import_id)
  end
end
