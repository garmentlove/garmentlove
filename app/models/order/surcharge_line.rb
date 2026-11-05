class Order::SurchargeLine < ApplicationRecord
  belongs_to :price_surcharge, class_name: "Price::Surcharge"
  belongs_to :order

  def price_cents(subtotal_cents)
    case price_surcharge.modifer
    when "add"
      price_surcharge.amount
    when "subtract"
      -price_surcharge.amount
    when "procentage"
      (subtotal_cents * price_surcharge.amount / 100.0).round
    else
      0
    end
  end
end
