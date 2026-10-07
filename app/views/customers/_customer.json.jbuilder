json.extract! customer, :id, :first_name, :last_name, :name, :sortable_name, :initials, :created_at, :updated_at

json.type customer.customer_type
json.address customer.address&.mailing
json.billing_address customer.billing_address&.mailing
json.cellphone customer.cellphone&.number

json.url customer_url(customer, format: :json)
