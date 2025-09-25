class CreateEndpointConfigurations < ActiveRecord::Migration[8.0]
  def change
    create_table :endpoint_configurations do |t|
      t.bigint :organisation_id
      t.bigint :endpoint_monitoring_group_id

      # polymorphic
      t.bigint :associated_resoures_id
      t.string :associated_resoures_type

      t.timestamps
    end

    add_index :endpoint_configurations, [ :associated_resoures_type, :associated_resoures_id ], name: "index_endpoint_configs_on_associated_resource"
  end
end
