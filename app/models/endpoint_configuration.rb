class EndpointConfiguration < ApplicationRecord
  belongs_to :endpoint_monitoring_group

  validates :tenant_id, :router_id, presence: true

  after_commit :cache_to_redis, on: [ :create, :update ]

  private

  def cache_to_redis
    key = "endpoint_configurations:#{router_id}"
    data = {
      id: id,
      tenant_id: tenant_id,
      router_id: router_id,
      endpoint_monitoring_group: {
        name: endpoint_monitoring_group.name,
        endpoint_monitoring_endpoints: endpoint_monitoring_group.endpoint_monitoring_endpoints.map do |e|
          {
            host: e.host,
            monitoring_mode: e.monitoring_mode,
            monitor_method: e.monitor_method,
            critical: e.critical,
            warning: e.warning
          }
        end
      }
    }
    $redis.set(key, data.to_json)
  end
end

# $redis.set(key, data.to_json, ex: 1.hour)
