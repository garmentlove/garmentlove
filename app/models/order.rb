class Order < ApplicationRecord
  belongs_to :customer

  has_many :line_items, class_name: "Order::LineItem", dependent: :destroy
  has_many :items, through: :line_items
  has_many :surcharge_lines, class_name: "Order::SurchargeLine", dependent: :destroy
  has_many :surcharges, through: :surcharge_lines, source: :price_surcharge

  enum :status, %w[ pending closed completed ]
  enum :order_type, %w[ cleaning wash_and_fold retail ].index_by(&:itself), default: :cleaning

  after_create :create_item_for_wash_and_fold, if: ->(order) { order.wash_and_fold? }

  monetize :price_cents

  def add_item_by_barcode(barcode)
    line_items.create(item: Item.find_or_create_by_barcode(barcode))
  end

  def pieces
    line_items.sum(:quantity)
  end

  def price_cents
    line_items.map(&:price_cents).sum
  end

  private
    def create_item_for_wash_and_fold
      line_items.create!(item: Item.create!)
    end
end
