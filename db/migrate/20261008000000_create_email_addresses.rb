class CreateEmailAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :email_addresses do |t|
      t.string :address, null: false
      t.integer :designation, default: 0, null: false
      t.references :emailable, polymorphic: true, null: false

      t.timestamps
    end
    add_index :email_addresses, :address, unique: true
  end
end
