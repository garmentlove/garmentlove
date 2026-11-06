module Shippable
  extend ActiveSupport::Concern

  included do
    has_many :addresses, as: :addressable, dependent: :destroy
    has_one :address, -> { primary }, as: :addressable, dependent: :destroy
    has_one :billing_address, -> { billing }, class_name: "Address", as: :addressable, dependent: :destroy

    accepts_nested_attributes_for :address, :billing_address, allow_destroy: true, reject_if: :all_blank
  end

  def billing_address
    super || address
  end

  def avaliable_address_designations
    Address.designations.keys - self.addresses.pluck(:designation)
  end
end
