require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "rental orders require a fulfillment date" do
    order = Order.new(customer: customers(:one), order_type: :rental, due_at: Time.current)

    assert_not order.valid?
    assert_includes order.errors.attribute_names, :fulfillment_date
  end

  test "weekly presets require a target day and season" do
    order = Order.new(customer: customers(:one), order_type: :rental, due_at: Time.current, fulfillment_date: Date.current, weekly_preset: true)

    assert_not order.valid?
    assert_includes order.errors.attribute_names, :target_day
    assert_includes order.errors.attribute_names, :season
  end
end
