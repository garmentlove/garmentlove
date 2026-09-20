require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "name" do
    assert_equal "MW", customers(:one).initials
    assert_equal "Madelaine Witting", customers(:one).name
    assert_equal "Witting, Madelaine", customers(:one).sortable_name
  end
end
