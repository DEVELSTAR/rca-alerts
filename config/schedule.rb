env :PATH, ENV["PATH"]   # ensure your Ruby/bundler path is passed to cron
set :output, "/Users/akibu/Desktop/rca-alerts/log/cron.log"

every 1.minutes do
  runner "RcaDetector.run", environment: :development
end

every 1.minutes do
  runner "AlertDispatcher.run", environment: :development
end
