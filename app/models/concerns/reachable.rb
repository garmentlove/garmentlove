module Reachable
  extend ActiveSupport::Concern

  included do
    has_one :cellphone, -> { cell }, class_name: "Telephone",
            as: :reachable, dependent: :destroy
    has_one :homephone, -> { home }, class_name: "Telephone",
            as: :reachable, dependent: :destroy

    accepts_nested_attributes_for :cellphone, :homephone,
                                  allow_destroy: true, reject_if: :all_blank
  end
end
