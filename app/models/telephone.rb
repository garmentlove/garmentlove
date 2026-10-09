class Telephone < ApplicationRecord
  belongs_to :reachable, polymorphic: true

  validates :number, presence: true, phone: true, uniqueness: { scope: :reachable_type }

  enum :designation, %w[ cellphone home ], default: :cellphone

  normalizes :number, with: ->(n) { Phonelib.parse(n).sanitized }

  def to_s
    number
  end
end
