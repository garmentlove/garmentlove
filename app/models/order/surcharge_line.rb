class Order::SurchargeLine < ApplicationRecord
  belongs_to :price_surcharge, class_name: "Price::Surcharge"
  belongs_to :order
end
