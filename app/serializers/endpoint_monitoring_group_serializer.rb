class EndpointMonitoringGroupSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :group_type

  attribute :endpoints do |group|
    group.endpoint_monitoring_endpoints.map do |e|
      {
        id: e.id,
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
  end
end
