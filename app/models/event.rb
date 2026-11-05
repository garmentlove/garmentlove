class Event < ApplicationRecord
  belongs_to :eventable, polymorphic: true, optional: true
  belongs_to :creator, polymorphic: true, optional: true

  scope :from_api, -> { where(authentication_type: "bearer") }
  scope :from_web, -> { where(authentication_type: "session") }

  def api?
    authentication_type == "bearer"
  end

  def web?
    authentication_type == "session"
  end
end
