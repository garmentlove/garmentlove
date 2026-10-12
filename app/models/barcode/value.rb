class Barcode::Value
  class << self
    def generate(length = 8)
      SecureRandom.alphanumeric(length)
    end
  end
end
