require "test_helper"

class AddressTest < ActiveSupport::TestCase
  test "mailing combines fields" do
    address = addresses(:one)
    expected = [ address.street,
                 address.street2,
                 address.city,
                 address.state,
                 address.zip,
                 address.country ].compact.join(" ")
    assert_equal expected, address.mailing
  end

  test "normalizes fields to uppercase" do
    address = Address.create!(street: "  Main St  ",
                              street2: " Apt 5 ",
                              city: " new york ",
                              state: "ny ",
                              country: " us ",
                              zip: " 12345 ",
                              designation: :primary,
                              addressable: customers(:one))
    assert_equal "MAIN ST", address.street
    assert_equal "APT 5", address.street2
    assert_equal "NEW YORK", address.city
    assert_equal "NY", address.state
    assert_equal "US", address.country
    assert_equal "12345", address.zip
  end

  test "validates presence of required fields" do
    address = Address.new
    refute address.valid?
    [ :street, :city, :state, :country, :zip ].each do |attr|
      assert_includes address.errors[attr], "can't be blank"
    end
  end
end
