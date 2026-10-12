class CreateItems < ActiveRecord::Migration[8.2]
  def change
    create_table :items do |t|
      t.references :customer, null: true, foreign_key: true
      t.string :name
      t.text :description
      t.boolean :ownable, default: true, null: false
      t.integer :status, default: 0, null: false
      t.decimal :weight, precision: 8, scale: 2
      t.integer :bundle_quantity, null: false, default: 1
      t.boolean :active, null: false, default: true

      t.integer :manual_price_cents, null: true
      t.integer :unit_price_cents, null: true

      t.timestamps
    end
  end
end
