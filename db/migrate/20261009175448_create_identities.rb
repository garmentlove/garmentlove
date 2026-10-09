class CreateIdentities < ActiveRecord::Migration[8.2]
  def change
    create_table :identities do |t|
      t.references :userable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
