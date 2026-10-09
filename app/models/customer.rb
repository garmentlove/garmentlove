class Customer < ApplicationRecord
  attr_accessor :skip_unique_name_validation

  has_one :address, -> { primary }, as: :addressable, dependent: :destroy
  has_one :billing_address, -> { billing }, class_name: "Address", as: :addressable, dependent: :destroy

  has_one :cellphone, -> { cell }, class_name: "Telephone", as: :reachable, dependent: :destroy
  has_one :homephone, -> { home }, class_name: "Telephone", as: :reachable, dependent: :destroy

  has_one :email, -> { primary }, class_name: "EmailAddress", as: :emailable, dependent: :destroy
  has_one :secondary_email, -> { secondary }, class_name: "EmailAddress", as: :emailable, dependent: :destroy

  validates :last_name, presence: true
  validates :first_name,
            uniqueness: { scope: :last_name, message: "and last name already exists" },
            unless: :skip_unique_name_validation,
            on: :create

  enum :customer_type, %w[ customer lead ].index_by(&:itself), default: :customer

  accepts_nested_attributes_for :address, :billing_address, :cellphone, :homephone, :email, :secondary_email,
                                allow_destroy: true, reject_if: :all_blank

  def to_s
    name
  end

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
