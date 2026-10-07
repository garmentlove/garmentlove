class Telephone < ApplicationRecord
  belongs_to :reachable, polymorphic: true

  validates :number, presence: true, phone: true

  enum :designation, %w[ cellphone home ], default: :cellphone

  normalizes :number, with: ->(n) { Phonelib.parse(n).sanitized }
end
