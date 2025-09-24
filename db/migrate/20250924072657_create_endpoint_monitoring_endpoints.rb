class CreateEndpointMonitoringEndpoints < ActiveRecord::Migration[8.0]
  def change
    create_table :endpoint_monitoring_endpoints do |t|
      t.references :endpoint_monitoring_group, null: false, foreign_key: true
      t.string :endpoint, null: false
      t.string :host, null: false
      t.string :monitoring_mode, null: false
      t.string :monitor_method, null: false
      t.integer :critical
      t.integer :warning

      t.timestamps
    end
  end
end
