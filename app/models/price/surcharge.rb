class Price::Surcharge < ApplicationRecord
  enum :modifer, %w[ add subtract procentage ]
end
