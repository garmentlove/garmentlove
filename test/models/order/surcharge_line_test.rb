require "test_helper"

class Order::SurchargeLineTest < ActiveSupport::TestCase
  test "returns fixed surcharges in cents" do
    surcharge = Price::Surcharge.new(modifer: :add, amount: 350)
    surcharge_line = Order::SurchargeLine.new(price_surcharge: surcharge)

    assert_equal 350, surcharge_line.price_cents(1_000)
  end

  test "calculates percentage surcharges against the order subtotal" do
    surcharge = Price::Surcharge.new(modifer: :procentage, amount: 10)
    surcharge_line = Order::SurchargeLine.new(price_surcharge: surcharge)

    assert_equal 101, surcharge_line.price_cents(1_005)
  end

  test "subtracts fixed surcharges from the order total" do
    surcharge = Price::Surcharge.new(modifer: :subtract, amount: 250)
    surcharge_line = Order::SurchargeLine.new(price_surcharge: surcharge)

    assert_equal(-250, surcharge_line.price_cents(1_000))
  end
end
