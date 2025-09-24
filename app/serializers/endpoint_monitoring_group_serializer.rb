class EndpointMonitoringGroupSerializer
  include JSONAPI::Serializer

  attributes :id, :name

  attribute :endpoints do |group|
    group.endpoint_monitoring_endpoints.map do |e|
      {
        id: e.id,
        host: e.host,
        monitoring_mode: e.monitoring_mode,
        monitor_method: e.monitor_method,
        critical: e.critical,
        warning: e.warning
      }
    end
  end
end
