class EndpointMonitoringEndpoint < ApplicationRecord
  belongs_to :endpoint_monitoring_group

  MONITORING_MODES = %w[icmp tcp http ping wget].freeze

  validates :monitoring_mode, inclusion: { in: MONITORING_MODES }
  validates :endpoint_name, :host, presence: true

  validates :port,
            :latency_critical, :latency_warning,
            :packet_loss_critical, :packet_loss_warning,
            :response_time,
            numericality: { only_integer: true }, allow_nil: true
end
