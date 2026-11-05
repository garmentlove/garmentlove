json.extract! order, :id, :order_type, :due_at, :rush, :pieces_count, :notes, :fulfillment_date, :weekly_preset, :target_day, :season

json.customer do
  json.extract! order.customer, :id, :name
  json.url customer_url(order.customer, format: :json)
end

json.items do
  json.array! order.line_items do |line_item|
    json.extract! line_item.item, :id, :name
    json.barcode line_item.item.barcode&.value
    json.url order_item_url(order, line_item, format: :json)
  end
end

json.url order_url(order)
