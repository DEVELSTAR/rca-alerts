class AddAlertedToRcaEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :rca_events, :alerted, :boolean
  end
end
