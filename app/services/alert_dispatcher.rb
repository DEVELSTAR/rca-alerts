# app/services/alert_dispatcher.rb
class AlertDispatcher
  def self.run
    RcaEvent.where(status: "open", alerted: [ nil, false ])
            .where("ts > ?", 15.minutes.ago)
            .find_each do |event|
      send_slack(event)
      # send_email(event)
      # send_webhook(event)
      event.update(alerted: true)
    end
  end

  def self.send_slack(event)
    webhook_url = ENV["SLACK_WEBHOOK_URL"]

    return unless webhook_url

    payload = {
      text: "[#{event.severity.upcase}] #{event.metric_type} alert\nLocation: #{event.location}\nISP: #{event.isp}\nEndpoint: #{event.endpoint}\nMessage: #{event.message}"
    }

    require "net/http"
    require "uri"
    require "json"

    uri = URI(webhook_url)
    Net::HTTP.post(uri, payload.to_json, "Content-Type" => "application/json")
  end

  def self.send_email(event)
    # Use ActionMailer or external service like SendGrid
    AlertMailer.with(event: event).alert_email.deliver_later
  end

  def self.send_webhook(event)
    webhook_url = ENV["ALERT_WEBHOOK_URL"]
    return unless webhook_url

    payload = event.as_json
    uri = URI(webhook_url)
    Net::HTTP.post(uri, payload.to_json, "Content-Type" => "application/json")
  end
end
