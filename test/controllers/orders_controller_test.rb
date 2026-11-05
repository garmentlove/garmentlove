require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "starts the POS flow by selecting or creating a customer" do
    get new_order_url

    assert_response :success
    assert_select "turbo-frame#order_flow" do
      assert_select "h2", text: "Select or create a customer"
      assert_select 'select[name="customer_id"][required]'
      assert_select 'a[data-turbo-frame="order_flow"][href*="return_to_order"]', text: /Create a new customer/
    end
  end

  test "selects an order type after the customer step" do
    get new_order_url(step: "order_type", customer_id: customers(:one).id), headers: { "Turbo-Frame" => "order_flow" }

    assert_response :success
    assert_select "turbo-frame#order_flow" do
      assert_select "h2", text: "Select an order type"
      assert_select 'a[data-turbo-frame="order_flow"][href*="order_type=cleaning"]'
      assert_select 'a[data-turbo-frame="order_flow"][href*="order_type=wash_and_fold"]'
      assert_select 'a[data-turbo-frame="order_flow"][href*="order_type=retail"]'
      assert_select 'a[data-turbo-frame="order_flow"][href*="order_type=rental"]'
    end
  end

  test "renders order values and staged item camera flow after selecting type" do
    get new_order_url(step: "order_values", customer_id: customers(:one).id, order_type: "rental")

    assert_response :success
    assert_select 'form[data-turbo-frame="_top"]' do
      assert_select 'input[name="order[customer_id]"][value=?]', customers(:one).id.to_s
      assert_select 'input[name="order[order_type]"][value="rental"]'
      assert_select 'input[name="order[due_at]"][type="datetime-local"][required]'
      assert_select 'input[name="order[fulfillment_date]"][required]'
      assert_select 'turbo-frame#order_line_items[data-order-type="rental"]' do
        assert_select 'input[data-item-entry-target="barcodeInput"]'
        assert_select 'input[type="file"][accept="image/*"][capture="environment"]'
        assert_select "video[data-photo-markup-target=video]"
        assert_select 'li[data-item-entry-target="stepLabel"]', count: 3
        assert_select 'select[name="order[target_day]"]'
      end
    end
  end

  test "renders the wash and fold item with weight and photo steps" do
    get new_order_url(step: "order_values", customer_id: customers(:one).id, order_type: "wash_and_fold")

    assert_response :success
    assert_select 'input[name="order[line_items_attributes][0][item_attributes][weight]"]'
    assert_select 'input[type="file"][accept="image/*"][capture="environment"]'
  end

  test "renders the selected dry cleaning type inside the item frame" do
    get new_order_url(step: "order_values", customer_id: customers(:one).id, order_type: "cleaning")

    assert_response :success
    assert_select 'turbo-frame#order_line_items[data-order-type="cleaning"]' do
      assert_select 'template[data-order-form-target="itemTemplate"]'
      assert_select 'input[name*="[details][fabrics]"]'
      assert_select 'input[data-item-entry-target="barcodeField"]'
    end
  end

  test "customer creation from the order flow returns to order type selection" do
    assert_difference "Customer.count", 1 do
      post customers_url, params: {
        return_to_order: "true",
        customer: { first_name: "POS", last_name: "Customer" }
      }, headers: { "Turbo-Frame" => "order_flow" }
    end

    created_customer = Customer.find_by!(first_name: "POS", last_name: "Customer")
    assert_redirected_to new_order_url(step: "order_type", customer_id: created_customer.id)
  end

  test "the order type step cannot be skipped without a customer" do
    get new_order_url(step: "order_type")

    assert_response :success
    assert_select "h2", text: "Select or create a customer"
  end

  test "creates a dry cleaning order with a temporary garment item" do
    surcharge = price_surcharges(:one)
    surcharge.update!(amount: 250, modifer: :add)

    assert_difference [ "Order.count", "Item.count", "Order::LineItem.count", "Order::SurchargeLine.count" ], 1 do
      post orders_url, params: {
        order: {
          customer_id: customers(:one).id,
          order_type: "cleaning",
          due_at: "2026-10-15T16:30",
          rush: "1",
          pieces_count: "2",
          notes: "Please handle with care",
          surcharge_ids: [ surcharge.id ],
          line_items_attributes: {
            "0" => {
              quantity: "2",
              item_attributes: {
                name: "Wool blazer",
                description: "Navy, single-breasted",
                manual_price: "12.50",
                barcode_value: "",
                annotations: '[{"type":"spot","note":"small mark","x":22.5,"y":47}]',
                details: {
                  item_type: "Blazer",
                  colors: "Navy",
                  fabrics: "Wool",
                  brand: "Atelier",
                  pattern: "Solid"
                }
              }
            }
          }
        }
      }
    end

    order = Order.last
    assert_redirected_to order_url(order)
    assert order.rush?
    assert_equal 2, order.pieces
    assert_equal "Please handle with care", order.notes
    assert_equal "Wool blazer", order.line_items.sole.item.name
    assert_equal "Navy", order.line_items.sole.item.details["colors"]
    assert_equal "small mark", order.line_items.sole.item.annotations.sole["note"]
    assert order.line_items.sole.item.barcode.value.present?
    assert_equal 2_750, order.price_cents
  end

  test "creates a rental order from bundled textile inventory with a weekly preset" do
    assert_difference [ "Order.count", "Order::LineItem.count" ], 1 do
      post orders_url, params: {
        order: {
          customer_id: customers(:one).id,
          order_type: "rental",
          due_at: "2026-10-15T16:30",
          fulfillment_date: "2026-10-16",
          weekly_preset: "1",
          target_day: "friday",
          season: "winter",
          pieces_count: "10",
          line_items_attributes: {
            "0" => { item_id: items(:king_flat).id, quantity: "2" }
          }
        }
      }
    end

    order = Order.last
    assert_redirected_to order_url(order)
    assert_equal Date.new(2026, 10, 16), order.fulfillment_date
    assert order.weekly_preset?
    assert_equal "friday", order.target_day
    assert_equal "winter", order.season
    assert_equal items(:king_flat), order.line_items.sole.item
  end

  test "creates wash and fold with one weighed service item" do
    assert_difference [ "Order.count", "Item.count", "Order::LineItem.count" ], 1 do
      post orders_url, params: {
        order: {
          customer_id: customers(:one).id,
          order_type: "wash_and_fold",
          due_at: "2026-10-15T16:30",
          line_items_attributes: {
            "0" => {
              quantity: "1",
              item_attributes: {
                name: "Wash & Fold",
                weight: "8.5",
                manual_price: "18.00",
                annotations: "[]"
              }
            }
          }
        }
      }
    end

    order = Order.last
    assert_redirected_to order_url(order)
    assert order.wash_and_fold?
    assert_equal BigDecimal("8.5"), order.line_items.sole.item.weight
    assert_equal 1, order.line_items.count
  end

  test "requires a line item" do
    assert_no_difference "Order.count" do
      post orders_url, params: {
        order: {
          customer_id: customers(:one).id,
          order_type: "retail",
          due_at: "2026-10-15T16:30"
        }
      }
    end

    assert_response :unprocessable_content
    assert_select ".gl-pos-errors", text: /Add at least one line item/
  end
end
