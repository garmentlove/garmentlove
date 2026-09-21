class AddCustomerTypeToCustomers < ActiveRecord::Migration[8.2]
  def change
    add_column :customers, :customer_type, :string, default: "customer", null: false
  end
end
