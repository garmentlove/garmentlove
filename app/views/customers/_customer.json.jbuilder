json.extract! customer, :id, :first_name, :last_name, :name, :sortable_name, :initials, :created_at, :updated_at

json.address do
  if customer.address
    json.partial! "addresses/address", address: customer.address
  else
    json.array! []
  end
end

json.billing_address do
  if customer.billing_address
    json.partial! "addresses/address", address: customer.billing_address
  else
    json.array! []
  end
end

json.url customer_url(customer, format: :json)
