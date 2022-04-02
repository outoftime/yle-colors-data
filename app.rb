require 'sinatra/base'
require 'sinatra/json'

require './environment'
require './db'

class YleColorsData < Sinatra::Base
  before do
    headers 'Access-Control-Allow-Origin' => '*',
     'Cache-Control' => 'public, s-max-age=900'
  end

  get '/states' do
    json(
      current_rolling_averages
      .distinct
      .select(:state)
      .map { |row| row[:state] }
      .sort
    )
  end

  get '/states/:state/counties' do |state|
    json(
      current_rolling_averages
        .where(state:)
        .distinct
        .select(:county)
        .map { |row| row[:county] }
        .sort
    )
  end

  get '/states/:state/counties/:county/7_day_cases_per_100k' do |state, county|
    row = current_rolling_averages
          .where(state:)
          .where(county:)
          .order(Sequel.desc(:date))
          .select(:cases_avg_per_100k, :date)
          .first
    json(
      "7_day_cases_per_100k": (row[:cases_avg_per_100k] * 7).round,
      date: row[:date].to_s
    )
  end

  private

  def current_rolling_averages
    DB[:us_counties_rolling_averages].where(
      import_id: current_import_id
    )
  end

  def current_import_id
    DB[:current_imports]
      .where(table: 'us_counties_rolling_averages')
      .select(:import_id)
  end
end
