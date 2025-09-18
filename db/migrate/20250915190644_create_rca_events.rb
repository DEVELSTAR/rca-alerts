class CreateRcaEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :rca_events do |t|
      t.datetime :ts
      t.string :location
      t.string :isp
      t.string :endpoint
      t.string :metric_type
      t.float :value
      t.float :baseline
      t.string :severity
      t.text :message
      t.string :status

      t.timestamps
    end
  end
end
