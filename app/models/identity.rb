class Identity < ApplicationRecord
  belongs_to :userable, polymorphic: true

  belongs_to :customer, foreign_key: :userable_id, class_name: "Customer", optional: true

  has_many :magic_links

  class << self
    def find_for_autentication(value)
      find_by_email(value) || find_by_cellphone(value)
    end

    def find_by_email(email_address)
      includes(customer: :email).find_by(customers: { email_addresses: { address: email_address } })
    end

    def find_by_cellphone(cellphone)
      includes(customer: :cellphone).find_by(customers: { telephones: { number: cellphone } })
    end
  end
end
