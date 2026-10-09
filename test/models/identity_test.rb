require "test_helper"

class IdentityTest < ActiveSupport::TestCase
  # Test polymorphic association to userable (Customer)
  test "userable association resolves to customer" do
    identity = identities(:one)
    assert_instance_of Customer, identity.userable
    assert_equal customers(:one), identity.userable
  end

  # Test optional customer association mirrors userable
  test "customer association returns same customer" do
    identity = identities(:one)
    assert_instance_of Customer, identity.customer
    assert_equal customers(:one), identity.customer
  end

  # Test lookup methods
  test "find_by_email returns correct identity" do
    identity = Identity.find_by_email("test@example.com")
    assert identity
    assert_equal identities(:one), identity
  end

  test "find_by_cellphone returns correct identity" do
    identity = Identity.find_by_cellphone("5555550100")
    assert identity
    assert_equal identities(:one), identity
  end

  test "find_for_autentication finds by email or cellphone" do
    identity_email = Identity.find_for_autentication("test@example.com")
    identity_phone = Identity.find_for_autentication("5555550100")
    assert_equal identities(:one), identity_email
    assert_equal identities(:one), identity_phone
  end
end
