class EmailAddress < ApplicationRecord
  belongs_to :emailable, polymorphic: true

  validates :address, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  enum :designation, %w[ primary secondary ], default: :primary

  normalizes :address, with: ->(e) { e.to_s.strip }
end
