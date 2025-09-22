class AlertDispatcherJob < ApplicationJob
  queue_as :critical

  def perform
    events = RcaEventService.active
    events.each do |event|
      puts "Events: #{event}........................"
      # AlertDispatcher.send_slack(event)
      # AlertDispatcher.send_email(event)
      # AlertDispatcher.send_webhook(event)
    end
  end
end
