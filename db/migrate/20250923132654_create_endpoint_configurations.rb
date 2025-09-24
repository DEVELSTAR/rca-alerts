class CreateEndpointConfigurations < ActiveRecord::Migration[8.0]
  def change
    create_table :endpoint_configurations do |t|
      t.integer :tenant_id
      t.integer :endpoint_monitoring_group_id
      t.integer :router_id

      t.timestamps
    end
  end
end
