task :environment do
  require "./environment"
end

namespace :db do
  task setup: :environment do
    require "sequel/core"
    Sequel.extension :migration
  end

  desc "Run migrations"
  task :migrate, [:version] => [:setup] do |_t, args|
    version = args[:version].to_i if args[:version]
    Sequel.connect(ENV.fetch("DATABASE_URL")) do |db|
      Sequel::Migrator.run(db, "db/migrations", target: version)
    end
  end

  desc "Roll back latest migration"
  task rollback: :setup do
    Sequel.connect(ENV.fetch("DATABASE_URL")) do |db|
      current = Sequel::IntegerMigrator.new(db, "db/migrations").current
      Sequel::Migrator.run(db, "db/migrations", target: current - 1)
    end
  end
end

namespace :data do
  desc "Import latest data from NYT API"
  task import: [:environment] do
    require "./new_york_times_import"
    NewYorkTimesImport.new.start

    require "./covid_act_now_import"
    CovidActNowImport.new.start
  end
end
