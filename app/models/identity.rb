class Identity < ApplicationRecord
  belongs_to :userable, polymorphic: true

  belongs_to :customer, foreign_key: :userable_id, class_name: "Customer", optional: true
  belongs_to :user, foreign_key: :userable_id, class_name: "User", optional: true

  scope :customers, -> { where(userable_type: "Customer") }
  scope :users, -> { where(userable_type: "User") }

  has_many :sessions, dependent: :destroy
  has_many :magic_links, dependent: :destroy
  has_many :access_tokens, dependent: :destroy

  class << self
    def find_for_authentication(value, with: :user)
      find_by_email(value, with: with) || find_by_cellphone(value, with: with) || find_by_username(value, with: with)
    end

    def find_by_email(email_address, with: :user)
      send(with.to_s.pluralize).includes(with.to_sym => :email).find_by(with.to_sym => { email_addresses: { address: email_address } })
    end

    def find_by_cellphone(cellphone, with: :user)
      send(with.to_s.pluralize).includes(with.to_sym => :cellphone).find_by(with.to_sym => { telephones: { number: cellphone } })
    end

    def find_by_username(username, with: :user)
      includes(:user).find_by(user: { username: username }) if with == :user
    end

    def find_by_permissable_access_token(token, method:)
      if (access_token = AccessToken.find_by(token: token)) && access_token.allows?(method)
        access_token.identity
      end
    end
  end

  def send_magic_link(**attributes)
    attributes[:purpose] = attributes.delete(:for) if attributes.key?(:for)

    magic_links.create!(attributes).tap do |magic_link|
      MagicLinkMailer.with(code: magic_link.code, email_address: email).sign_in.deliver_later
    end
  end

  def email
    userable.email&.address
  end

  def cellphone
    userable.cellphone&.number
  end
end
