require "ddtrace"
require "sequel"

Datadog.configure do |c|
  c.use :sequel
end

DB = Sequel.connect(ENV["DATABASE_URL"])
