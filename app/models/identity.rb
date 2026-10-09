class Identity < ApplicationRecord
  belongs_to :userable, polymorphic: true

  belongs_to :customer, foreign_key: :userable_id, class_name: "Customer", optional: true
  belongs_to :user, foreign_key: :userable_id, class_name: "User", optional: true

  has_many :sessions, dependent: :destroy
  has_many :magic_links, dependent: :destroy
  has_many :access_tokens, dependent: :destroy

  class << self
    def find_for_autentication(value, with: :user)
      find_by_email(value, with: with) || find_by_cellphone(value, with: with) || find_by_username(value, with: with)
    end

    def find_by_email(email_address, with: :user)
      includes(with.to_sym => :email).find_by(with.to_sym => { email_addresses: { address: email_address } })
    end

    def find_by_cellphone(cellphone, with: :user)
      includes(with.to_sym => :cellphone).find_by(with.to_sym => { telephones: { number: cellphone } })
    end

    def find_by_username(username, with: :user)
      includes(:user).find_by(user: { username: username }) if with == :user
    end
  end
end
