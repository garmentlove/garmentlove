module Shippable
  extend ActiveSupport::Concern

  included do
    has_one :address, -> { primary }, as: :addressable, dependent: :destroy
    has_one :billing_address, -> { billing }, class_name: "Address", as: :addressable, dependent: :destroy
  end

  def billing_address
    super || address
  end
end
