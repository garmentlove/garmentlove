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
    # User identity lookup by email
    user = identities(:user_one)
    identity = Identity.find_by_email(user.email)
    assert identity
    assert_equal user, identity

    # Customer identity lookup by email
    customer = identities(:one)
    identity = Identity.find_by_email(customer.email, with: :customer)
    assert identity
    assert_equal customer, identity
  end

  test "find_by_cellphone returns correct identity" do
    # User identity lookup by cellphone
    user = identities(:user_one)
    identity = Identity.find_by_cellphone(user.cellphone)
    assert identity
    assert_equal user, identity

    # Customer identity lookup by cellphone
    customer = identities(:one)
    identity = Identity.find_by_cellphone(customer.cellphone, with: :customer)
    assert identity
    assert_equal customer, identity
  end

  test "find_for_autentication finds by email, cellphone, or username" do
    # User identity lookup
    user = identities(:user_one)
    identity_username = Identity.find_for_authentication(user.userable.username)
    assert_equal user, identity_username

    identity_email = Identity.find_for_authentication(user.email)
    identity_phone = Identity.find_for_authentication(user.cellphone)
    assert_equal identities(:user_one), identity_email
    assert_equal identities(:user_one), identity_phone

    # Customer identity lookup
    customer = identities(:one)

    identity_email = Identity.find_for_authentication(customer.email, with: :customer)
    identity_phone = Identity.find_for_authentication(customer.cellphone, with: :customer)
    assert_equal identities(:one), identity_email
    assert_equal identities(:one), identity_phone
  end
end
