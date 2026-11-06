json.extract! customer, :id, :first_name, :last_name, :name, :sortable_name, :initials, :created_at, :updated_at

json.type customer.customer_type

json.cellphone customer.cellphone&.number
json.homephone customer.homephone&.number

json.email customer.email&.address

json.addresses customer.addresses do |address|
  json.extract! address, :designation, :street, :street2, :city, :state, :country, :zip
end

json.url customer_url(customer, format: :json)
