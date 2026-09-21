class Customer < ApplicationRecord
  attr_accessor :skip_unique_name_validation

  has_one :address, -> { primary }, as: :addressable
  has_one :billing_address, -> { billing }, class_name: "Address", as: :addressable

  validates :last_name, presence: true
  validates :first_name,
            uniqueness: { scope: :last_name, message: "and last name already exists" },
            unless: :skip_unique_name_validation,
            on: :create

  enum :customer_type, %w[ customer lead ].index_by(&:itself), default: :customer

  def name
    [ first_name, last_name ].compact.reject(&:empty?).join(" ")
  end

  def sortable_name
    [ last_name, first_name ].compact.reject(&:empty?).join(", ")
  end

  def initials
    [ first_name&.first, last_name.first(2) ].join.upcase.first(2)
  end

  def billing_address
    super || address
  end
end
