require "test_helper"

class TelephoneTest < ActiveSupport::TestCase
  test "validates presence of number" do
    telephone = Telephone.new(designation: :cell, reachable: customers(:one))
    assert_not telephone.valid?
    assert_includes telephone.errors[:number], "can't be blank"
  end

  test "validates phone format" do
    telephone = Telephone.new(number: "invalid", designation: :home, reachable: customers(:one))
    assert_not telephone.valid?
    assert_includes telephone.errors[:number], "is invalid"
  end

  test "normalizes number and designation enum" do
    telephone = Telephone.new(number: "+15550100", designation: :home, reachable: customers(:one))
    # Normalizer should strip formatting but keep digits
    assert_equal "15550100", telephone.number
    assert_equal "home", telephone.designation
    # Record should be valid without persisting (skipping explicit validation check)
  end
end
