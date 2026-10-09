class CreateTelephones < ActiveRecord::Migration[8.2]
  def change
    create_table :telephones do |t|
      t.integer :designation, null: false, default: 0
      t.string :number, null: false
      t.references :reachable, polymorphic: true, null: false

      t.timestamps
    end
    add_index :telephones, :number
  end
end
