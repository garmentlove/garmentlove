class CreateOrderLineItems < ActiveRecord::Migration[8.2]
  def change
    create_table :order_line_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
  end
end
