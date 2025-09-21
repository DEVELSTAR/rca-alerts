# rca-alerts/config/initializers/click_house.rb
ClickHouse.config do |config|
  config.url = ENV.fetch("CLICKHOUSE_URL", "http://127.0.0.1:8123")
  config.username = ENV["CLICKHOUSE_USER"]
  config.password = ENV["CLICKHOUSE_PASSWORD"]
  config.database = ENV.fetch("CLICKHOUSE_DB", "default")
  config.timeout = 5
  config.open_timeout = 2
end
