json.partial! "customers/customer", customer: @customer

json.addresses @customer.addresses do |address|
  json.partial! "app/addresses/address", address: address
end

json.url app_profile_url
