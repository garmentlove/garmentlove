class CreateItemDescriptors < ActiveRecord::Migration[8.2]
  def change
    create_table :item_descriptors do |t|
      t.references :item, null: false, foreign_key: true
      t.references :item_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
