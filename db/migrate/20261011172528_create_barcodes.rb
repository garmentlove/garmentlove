class CreateBarcodes < ActiveRecord::Migration[8.2]
  def change
    create_table :barcodes do |t|
      t.text :value, null: false
      t.integer :symbology, null: false, default: 0
      t.references :scannable, polymorphic: true, null: false

      t.timestamps
    end
    add_index :barcodes, :value
  end
end
