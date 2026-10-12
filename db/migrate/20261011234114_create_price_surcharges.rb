class CreatePriceSurcharges < ActiveRecord::Migration[8.2]
  def change
    create_table :price_surcharges do |t|
      t.integer :amount, null: false, default: 0
      t.text :description
      t.integer :modifer, null: false, default: 0

      t.timestamps
    end
  end
end
