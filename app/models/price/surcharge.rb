class Price::Surcharge < ApplicationRecord
  enum :modifer, %w[ add subtract procentage ]

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
