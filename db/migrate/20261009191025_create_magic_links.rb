class CreateMagicLinks < ActiveRecord::Migration[8.2]
  def change
    create_table :magic_links do |t|
      t.string :code, limit: 255, null: false
      t.datetime :expires_at, null: false
      t.references :identity, null: false, foreign_key: true
      t.integer :purpose

      t.timestamps
    end
  end
end
