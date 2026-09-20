class Customer < ApplicationRecord
  attr_accessor :skip_unique_name_validation

  validates :last_name, presence: true
  validates :first_name,
            uniqueness: { scope: :last_name, message: "and last name already exists" },
            unless: :skip_unique_name_validation,
            on: :create

  def name
    [ first_name, last_name ].reject(&:empty?).join(" ")
  end

  def sortable_name
    [ last_name, first_name ].reject(&:empty?).join(", ")
  end

  def initials
    [ first_name&.first, last_name[...2] ].join.upcase[...2]
  end
end
