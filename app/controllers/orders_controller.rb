class OrdersController < ApplicationController
  before_action :load_form_data, only: %i[ new create ]

  def new
    @customer = Customer.find_by(id: params[:customer_id])
    requested_type = params[:order_type].presence_in(Order.order_types.keys)
    @step = if params[:step] == "order_values" && @customer && requested_type
      "order_values"
    elsif params[:step] == "order_type" && @customer
      "order_type"
    else
      "customer"
    end
    @order = Order.new(order_type: requested_type || "cleaning")
    @order.line_items.build
  end

  def create
    @order = Order.new(order_params)
    @customer = @order.customer
    @step = @customer ? "order_values" : "customer"

    if line_item_params.blank?
      @order.errors.add(:base, "Add at least one line item.")
      @order.line_items.build
      return render :new, status: :unprocessable_content
    end

    Order.transaction do
      @order.save!
      line_item_params.each_value { |attributes| create_line_item(attributes) }
      selected_surcharge_ids.each do |id|
        @order.surcharge_lines.create!(price_surcharge: Price::Surcharge.find(id))
      end
    end

    redirect_to @order, notice: "Order was successfully created.", status: :see_other
  rescue ActiveRecord::RecordInvalid => error
    @order = Order.new(order_params)
    @customer = @order.customer
    @step = @customer ? "order_values" : "customer"
    @order.errors.add(:base, error.record.errors.full_messages.to_sentence)
    @order.line_items.build
    render :new, status: :unprocessable_content
  rescue JSON::ParserError => error
    @order = Order.new(order_params)
    @customer = @order.customer
    @step = @customer ? "order_values" : "customer"
    @order.errors.add(:base, error.message)
    @order.line_items.build
    render :new, status: :unprocessable_content
  end

  def show
    @order = Order.includes(:customer, line_items: { item: [ :barcode, photos_attachments: :blob ] }, surcharge_lines: :price_surcharge).find(params[:id])
  end

  private
    def load_form_data
      @customers = Customer.order(:last_name, :first_name)
      @catalog_items = Item.where(ownable: false, active: true).includes(:barcode).order(:name)
      @surcharges = Price::Surcharge.order(:description)
    end

    def order_params
      params.require(:order).permit(
        :customer_id, :order_type, :due_at, :rush, :pieces_count, :notes,
        :fulfillment_date, :weekly_preset, :target_day, :season
      )
    end

    def selected_surcharge_ids
      params.require(:order).permit(surcharge_ids: []).fetch(:surcharge_ids, [])
    end

    def line_item_params
      params.require(:order).permit(
        line_items_attributes: [
          :item_id, :quantity,
          { item_attributes: [
            :name, :description, :ownable, :manual_price, :unit_price, :weight,
            :bundle_quantity, :barcode_value, :annotations,
            { photos: [], details: [ :item_type, :colors, :fabrics, :brand, :pattern ] }
          ] }
        ]
      ).fetch(:line_items_attributes, ActionController::Parameters.new)
    end

    def create_line_item(attributes)
      attributes = attributes.to_h
      item = if attributes["item_id"].present?
        Item.find(attributes["item_id"])
      else
        create_item(attributes.fetch("item_attributes", {}))
      end

      @order.line_items.create!(item: item, quantity: attributes.fetch("quantity", 1))
    end

    def create_item(attributes)
      attributes = attributes.to_h.symbolize_keys
      photos = attributes.delete(:photos) || []
      details = attributes.delete(:details)&.to_h || {}
      barcode_value = attributes.delete(:barcode_value).to_s.strip
      annotations = attributes.delete(:annotations).to_s

      item = Item.where(ownable: true).joins(:barcode).find_by(barcodes: { value: barcode_value }) if barcode_value.present?
      new_item = item.nil?
      item ||= Item.new
      item_attributes = attributes.except(:ownable)
      item_attributes = item_attributes.reject { |_key, value| value.blank? } unless new_item
      item.assign_attributes(item_attributes)
      item.ownable = @order.cleaning? if new_item
      item.manual_price = 0 if item.manual_price.blank? && item.unit_price.blank?
      item.bundle_quantity = 1 if item.bundle_quantity.blank?
      item.details = (item.details || {}).merge(details.reject { |_key, value| value.blank? })
      item.barcode ||= item.build_barcode
      item.barcode.value = barcode_value if new_item && barcode_value.present?
      parsed_annotations = JSON.parse(annotations.presence || "[]")
      item.annotations = parsed_annotations if new_item || photos.present? || parsed_annotations.any?
      item.photos.attach(photos) if photos.present?

      if @order.wash_and_fold? && item.weight.blank?
        item.errors.add(:weight, "is required for wash & fold")
        raise ActiveRecord::RecordInvalid, item
      end
      if barcode_value.blank? && item.name.blank?
        item.errors.add(:name, "can't be blank")
        raise ActiveRecord::RecordInvalid, item
      end

      unless item.annotations.is_a?(Array) && parsed_annotations.is_a?(Array)
        item.errors.add(:annotations, "must be a list of photo marks")
        raise ActiveRecord::RecordInvalid, item
      end

      item.save!
      item
    end
end
