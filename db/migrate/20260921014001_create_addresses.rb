class CreateAddresses < ActiveRecord::Migration[8.2]
  def change
    create_table :addresses do |t|
      t.integer :designation, null: false, default: 0
      t.string :street, null: false
      t.string :street2
      t.string :city, null: false
      t.string :state, null: false
      t.string :country, null: false
      t.string :zip, null: false
      t.references :addressable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
