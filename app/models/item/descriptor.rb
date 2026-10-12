class Item::Descriptor < ApplicationRecord
  belongs_to :item
  belongs_to :category, class_name: "Item::Category", foreign_key: :item_category_id

  validates :item, uniqueness: { scope: :item_category_id, message: "can only have one descriptor per category" }
end
