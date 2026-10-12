class Barcode < ApplicationRecord
  VALUE_LENGTH = 8

  belongs_to :scannable, polymorphic: true

  validates :value, presence: true, uniqueness: true
  before_validation :generate_value

  private
    def generate_value
      self.value ||= loop do
        candidate = Barcode::Value.generate(VALUE_LENGTH)
        break candidate unless self.class.exists?(value: candidate)
      end
    end
end
