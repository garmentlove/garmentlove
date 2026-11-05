require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @customer = customers(:one)
  end

  test "should get index" do
    get customers_url
    assert_response :success
  end

  test "should get new" do
    get new_customer_url
    assert_response :success
  end

  test "renders the new customer form in the POS turbo frame" do
    get new_customer_url(return_to_order: true), headers: { "Turbo-Frame" => "order_flow" }

    assert_response :success
    assert_select "turbo-frame#order_flow" do
      assert_select 'input[name="return_to_order"][value="true"]'
      assert_select "h1", text: "Add a customer"
    end
  end

  test "should create customer" do
    assert_difference("Customer.count") do
      post customers_url, params: { customer: { first_name: "Cristie", last_name: "Bednar" } }
    end

    assert_redirected_to customer_url(Customer.last)
  end

  test "should show customer" do
    get customer_url(@customer)
    assert_response :success
  end

  test "should get edit" do
    get edit_customer_url(@customer)
    assert_response :success
  end

  test "should update customer" do
    patch customer_url(@customer), params: { customer: { first_name: @customer.first_name, last_name: @customer.last_name } }
    assert_redirected_to customer_url(@customer)
  end

  test "should destroy customer" do
    assert_difference("Customer.count", -1) do
      delete customer_url(@customer)
    end

    assert_redirected_to customers_url
  end
end
