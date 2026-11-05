class Item < ApplicationRecord
  has_many_attached :photos

  belongs_to :customer, optional: true

  has_one :barcode, as: :scannable, dependent: :destroy
  has_many :descriptors, class_name: "Item::Descriptor", foreign_key: :item_id

  has_many :order_line_items, class_name: "Order::LineItem", dependent: :destroy
  has_many :orders, through: :order_line_items

  validate :can_set_manual_price
  validates :ownable, inclusion: { in: [ true, false ] }

  enum :status, %w[ draft detailed ]

  accepts_nested_attributes_for :descriptors, :barcode, allow_destroy: true

  before_save :remove_customer, unless: :ownable?
  after_initialize :build_default_barcode, if: :new_record?

  monetize :manual_price_cents, allow_nil: true
  monetize :unit_price_cents, allow_nil: true
  monetize :total_bundle_price_cents, allow_nil: true
  monetize :price_cents

  class << self
    def find_or_create_by_barcode(value)
      item = Item.joins(:barcode).find_by(barcodes: { value: value })
      item ||= create!
      item.barcode ||= Barcode.create!(scannable: item, value: value)
      item
    end
  end

  def price_cents
    manual_price_cents || total_bundle_price_cents || 0
  end

  def total_bundle_price_cents
    (unit_price_cents * bundle_quantity) unless unit_price_cents.nil?
  end

  private
    def build_default_barcode
      build_barcode if barcode.nil?
    end

    def remove_customer
      self.customer = nil
    end

    def can_set_manual_price
      unless manual_price_cents.present? || unit_price_cents.present?
        errors.add(:price, "must be manually set or have a unit price")
      end
    end
end
