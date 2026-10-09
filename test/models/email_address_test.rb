require "test_helper"

class EmailAddressTest < ActiveSupport::TestCase
  def setup
    @customer = Customer.create!(first_name: "Test", last_name: "User")
    @email = EmailAddress.new(address: "example@example.com", designation: :primary, emailable: @customer)
  end

  test "valid email" do
    assert @email.valid?
  end

  test "invalid email format" do
    @email.address = "invalid-email"
    refute @email.valid?
    assert_includes @email.errors[:address], "is invalid"
  end

  test "presence validation" do
    @email.address = nil
    refute @email.valid?
    assert_includes @email.errors[:address], "can't be blank"
  end
end
