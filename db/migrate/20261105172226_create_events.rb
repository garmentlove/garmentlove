class CreateEvents < ActiveRecord::Migration[8.2]
  def change
    create_table :events do |t|
      t.references :eventable, polymorphic: true, null: true
      t.references :creator, polymorphic: true, null: true
      t.string :controller
      t.string :action
      t.string :method, null: false, default: "text/html", null: false
      t.string :authentication_type
      t.string :format

      t.timestamps
    end
  end
end
