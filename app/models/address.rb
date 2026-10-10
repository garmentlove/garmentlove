class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validates :street, :city, :state, :country, :zip, presence: true

  enum :designation, %w[ primary billing ], default: :primary

  normalizes :street, :street2, :city, :state, :country, :zip,
             with: ->(value) { value.strip.upcase }

  def to_s
    mailing
  end

  def mailing
    [ street, street2, city, state, zip, country ].compact.reject(&:empty?).join(" ")
  end
end
