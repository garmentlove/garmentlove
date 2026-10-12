class CreateOrderSurchargeLines < ActiveRecord::Migration[8.2]
  def change
    create_table :order_surcharge_lines do |t|
      t.references :price_surcharge, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
