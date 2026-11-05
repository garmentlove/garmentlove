class Order < ApplicationRecord
  belongs_to :customer

  has_many :line_items, class_name: "Order::LineItem", dependent: :destroy
  has_many :items, through: :line_items
  has_many :surcharge_lines, class_name: "Order::SurchargeLine", dependent: :destroy
  has_many :surcharges, through: :surcharge_lines, source: :price_surcharge

  enum :status, %w[ pending closed completed ]
  enum :order_type, %w[ cleaning wash_and_fold retail rental ].index_by(&:itself), default: :cleaning

  monetize :price_cents

  validates :due_at, presence: true
  validates :pieces_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :fulfillment_date, presence: true, if: :rental?
  validates :target_day, :season, presence: true, if: -> { rental? && weekly_preset? }
  validates :target_day, inclusion: { in: Date::DAYNAMES.map(&:downcase) }, if: -> { rental? && weekly_preset? && target_day.present? }
  validates :season, inclusion: { in: %w[ year-round spring summer autumn winter ] }, if: -> { rental? && weekly_preset? && season.present? }

  before_validation { self.pieces_count ||= 0 }

  def add_item_by_barcode(barcode)
    line_items.create(item: Item.find_or_create_by_barcode(barcode))
  end

  def pieces
    pieces_count.to_i.positive? ? pieces_count : line_items.sum(:quantity)
  end

  def price_cents
    subtotal = line_items.sum(&:price_cents)
    subtotal + surcharge_lines.sum { |line| line.price_cents(subtotal) }
  end
end
