# app/mailers/alert_mailer.rb
class AlertMailer < ApplicationMailer
  def alert_email
    @event = params[:event]
    mail(to: "team@example.com", subject: "[#{@event.severity.upcase}] #{@event.metric_type} alert")
  end
end
