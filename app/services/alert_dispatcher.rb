# app/services/alert_dispatcher.rb
class AlertDispatcher
  def self.send_slack(event)
    webhook_url = ENV["SLACK_WEBHOOK_URL"]
    return unless webhook_url

    payload = {
      text: "[ALERT] Latency: #{event['avg_latency']}, Packet Loss: #{(event['packet_loss']*100).round(1)}%, HTTP Failures: #{event['http_failures']} Location: #{event['location']}, ISP: #{event['isp']}, Endpoint: #{event['endpoint']}"
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

    uri = URI(webhook_url)
    Net::HTTP.post(uri, event.to_json, "Content-Type" => "application/json")
  end
end
