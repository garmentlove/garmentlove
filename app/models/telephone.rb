class Telephone < ApplicationRecord
  belongs_to :reachable, polymorphic: true

  validates :number, presence: true, phone: true, uniqueness: { scope: :reachable_type }

  enum :designation, %w[ cell home ], default: :cell

  normalizes :number, with: ->(n) { Phonelib.parse(n).sanitized }

  def to_s
    number
  end
end
