class User < ApplicationRecord
  include Identifiable, Emailable, Reachable

  validates :username, :email, presence: true

  def to_s
    "@#{username}"
  end
end
