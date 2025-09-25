class EndpointMonitoringGroup < ApplicationRecord
  has_many :endpoint_monitoring_endpoints, dependent: :destroy
  has_many :endpoint_configurations, dependent: :destroy

  accepts_nested_attributes_for :endpoint_monitoring_endpoints, allow_destroy: true

  validates :name, presence: true
end
