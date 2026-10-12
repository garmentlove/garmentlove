class Order::LineItem < ApplicationRecord
  attr_accessor :transfer_item, :skip_order_pending_check

  belongs_to :order
  belongs_to :item

  validate :order_must_not_be_wash_and_fold
  validate :order_must_be_pending, on: :create, unless: :skip_order_pending_check
  validate :item_must_not_be_on_open_order
  validate :item_belongs_to_customer, unless: :transfer_item

  validates :item,
            uniqueness: { scope: :order, message: "has already been added to this order" },
            if: ->(line_item) { line_item.item.ownable? }

  before_save :assign_item_to_customer

  monetize :price_cents

  def price_cents
    (item.price_cents * quantity)
  end

  private
    def item_must_not_be_on_open_order
      if item.ownable?
        if item.orders.pending.any?
          errors.add(:item, "is on an open order")
        end
      end
    end

    def order_must_be_pending
      unless order.pending? || skip_order_pending_check
        errors.add(:order, "must be pending to add items")
      end
    end

    def assign_item_to_customer
      unless item.customer.present? || transfer_item.present?
        item.update(customer_id: order.customer_id)
      end
    end

    def item_belongs_to_customer
      if item.customer.present?
        if item.customer_id != order.customer_id
          errors.add(:item, "does not belong to this customer")
        end
      end
    end

    def order_must_not_be_wash_and_fold
      if order.wash_and_fold? && order.line_items.count > 0
        errors.add(:order, "cannot add items to a wash and fold order")
      end
    end
end
