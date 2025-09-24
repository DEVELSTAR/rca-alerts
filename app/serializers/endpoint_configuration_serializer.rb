class EndpointConfigurationSerializer
  include JSONAPI::Serializer

  attributes :id, :tenant_id, :router_id

  attribute :endpoint_monitoring_group do |config|
    next unless config.endpoint_monitoring_group

    {
      id: config.endpoint_monitoring_group.id,
      name: config.endpoint_monitoring_group.name,
      endpoints: config.endpoint_monitoring_group.endpoint_monitoring_endpoints.map do |e|
        {
          id: e.id,
          host: e.host,
          monitoring_mode: e.monitoring_mode,
          monitor_method: e.monitor_method,
          critical: e.critical,
          warning: e.warning
        }
      end
    }
  end
end
