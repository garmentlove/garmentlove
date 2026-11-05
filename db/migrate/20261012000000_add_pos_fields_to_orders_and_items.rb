class AddPosFieldsToOrdersAndItems < ActiveRecord::Migration[8.2]
  def change
    add_column :orders, :fulfillment_date, :date
    add_column :orders, :weekly_preset, :boolean, null: false, default: false
    add_column :orders, :target_day, :string
    add_column :orders, :season, :string
    add_column :items, :annotations, :json, null: false, default: []
    add_column :items, :details, :json, null: false, default: {}
  end
end
