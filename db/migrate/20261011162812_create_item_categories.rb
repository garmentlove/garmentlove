class CreateItemCategories < ActiveRecord::Migration[8.2]
  def change
    create_table :item_categories do |t|
      t.string :name, null: false
      t.string :color
      t.string :ancestry
      t.boolean :required, default: false
      t.boolean :active, default: true
      t.string :select, default: "single", null: false

      t.timestamps
    end
    add_index :item_categories, :name
    add_index :item_categories, :ancestry
  end
end
