class CreateAccessTokens < ActiveRecord::Migration[8.2]
  def change
    create_table :access_tokens do |t|
      t.references :identity, null: false, foreign_key: true
      t.string :token
      t.string :permission
      t.text :description

      t.timestamps
    end
  end
end
