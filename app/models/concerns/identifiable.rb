module Identifiable
  extend ActiveSupport::Concern

  included do
    has_one :identity, as: :userable, dependent: :destroy, autosave: true

    after_initialize :build_default_identity, if: :new_record?
  end

  private

  def build_default_identity
    build_identity if identity.nil?
  end
end
