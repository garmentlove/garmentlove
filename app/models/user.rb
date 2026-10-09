class User < ApplicationRecord
  include Identifiable, Emailable, Reachable

  validates :username, :email, presence: true
end
