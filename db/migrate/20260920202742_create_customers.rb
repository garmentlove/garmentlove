class CreateCustomers < ActiveRecord::Migration[8.2]
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name, null: false

      t.timestamps
    end
  end
end
