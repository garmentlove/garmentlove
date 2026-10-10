module Emailable
  extend ActiveSupport::Concern

  included do
    has_one :email, -> { primary }, class_name: "EmailAddress",
            as: :emailable, dependent: :destroy
    has_one :secondary_email, -> { secondary }, class_name: "EmailAddress",
            as: :emailable, dependent: :destroy

    accepts_nested_attributes_for :email, :secondary_email,
                                  allow_destroy: true,
                                  reject_if: ->(email) { email["address"].blank? }
  end

  def email=(address)
    (email || build_email).address = address
  end
end
