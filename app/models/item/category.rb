class Item::Category < ApplicationRecord
  has_ancestry

  has_one_attached :image

  validates :name, presence: true, uniqueness: true
  validates :required, inclusion: { in: [ true, false ] }
  validates :active, inclusion: { in: [ true, false ] }
  validates :color,
            format: { with: /\A#(?:\h{3}){1,2}\z/, message: "must be a valid CSS hex color code" },
            allow_blank: true

  enum :select, %w[ single multiple ].index_by(&:itself), default: :single
end
