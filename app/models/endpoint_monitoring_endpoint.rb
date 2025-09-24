class EndpointMonitoringEndpoint < ApplicationRecord
  belongs_to :endpoint_monitoring_group

  MONITORING_MODES = %w[icmp tcp http].freeze
  METHODS = %w[ping wget].freeze

  validates :monitor_method, inclusion: { in: METHODS }
  validates :monitoring_mode, inclusion: { in: MONITORING_MODES }

  validates :endpoint, :host, presence: true
  validates :critical, :warning, numericality: { only_integer: true }, allow_nil: true
end


# {
#  tenant_id: 1,
#  group_id: 1,
#  endpoints:
#   [
#     {
#       endpoint: "8.8.8.8",
#       host: "dns.google",
#       monitoring_mode: "icmp",
#       monitor_method: "ping",
#       critical: 300,
#       warning: 150
#     },
#     {
#       endpoint: "8.8.4.4",
#       host: "dns.google",
#       monitoring_mode: "http",
#       monitor_method: "ping",
#       critical: 300,
#       warning: 150
#     }
#   ]
# }
