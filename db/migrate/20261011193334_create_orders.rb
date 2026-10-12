class CreateOrders < ActiveRecord::Migration[8.2]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :order_type, null: false, default: "cleaning"
      t.datetime :due_at, null: false
      t.datetime :fulfill_at
      t.boolean :rush, null: false, default: false
      t.integer :pieces_count, null: false, default: 0
      t.text :notes
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
