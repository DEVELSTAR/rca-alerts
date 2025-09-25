class EndpointConfiguration < ApplicationRecord
  belongs_to :endpoint_monitoring_group

  ALLOWED_RESOURCE_TYPES = %w[
    LocationNetwork
    RouterInventory
    ActsAsTaggableOn::Tag
  ].freeze

  validates :organisation_id, :endpoint_monitoring_group_id, presence: true
  validates :associated_resoures_type, inclusion: { in: ALLOWED_RESOURCE_TYPES }

  after_commit :cache_to_redis, on: %i[create update]

  private

  def cache_to_redis
    key = "ep:#{id}"
    data = {
      id: id,
      organisation_id: organisation_id,
      endpoint_monitoring_group: {
        id: endpoint_monitoring_group.id,
        name: endpoint_monitoring_group.name,
        group_type: endpoint_monitoring_group.group_type,
        endpoints: endpoint_monitoring_group.endpoint_monitoring_endpoints.map do |e|
          {
            endpoint_name: e.endpoint_name,
            host: e.host,
            monitoring_mode: e.monitoring_mode,
            port: e.port,
            latency_critical: e.latency_critical,
            latency_warning: e.latency_warning,
            packet_loss_critical: e.packet_loss_critical,
            packet_loss_warning: e.packet_loss_warning,
            response_time: e.response_time,
            acceptable_response_codes: e.acceptable_response_codes
          }
        end
      }
    }
    $redis.set(key, data.to_json)
  end
end
