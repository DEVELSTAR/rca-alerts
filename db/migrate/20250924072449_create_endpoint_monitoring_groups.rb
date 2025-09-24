class CreateEndpointMonitoringGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :endpoint_monitoring_groups do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
