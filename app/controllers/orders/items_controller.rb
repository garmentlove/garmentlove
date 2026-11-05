class Orders::ItemsController < ApplicationController
  before_action :set_order
  before_action :set_item, only: [ :show, :edit, :update, :destroy ]
  before_action :load_form_data, only: [ :new, :create, :edit, :update ]

  def index
    @line_items = @order.line_items.includes(:item)
    respond_to do |format|
      format.html
      format.json { render json: @line_items }
    end
  end

  def show
    @line_item = @item
  end

  # GET /orders/:order_id/items/new
  def new
    @step = params[:step] || "select_item"
    @item = @order.line_items.build
  end

  # POST /orders/:order_id/items
  def create
    @step = "review"
    @item = @order.line_items.build(line_item_params)
    if @item.save
      redirect_to [ @order, @item ], notice: "Item added to order.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /orders/:order_id/items/:id/edit
  def edit
    @step = "edit"
  end

  # PATCH/PUT /orders/:order_id/items/:id
  def update
    if @item.update(line_item_params)
      redirect_to [ @order, @item ], notice: "Item updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /orders/:order_id/items/:id
  def destroy
    @item.destroy
    redirect_to order_items_path(@order), notice: "Item removed."
  end

  private
    def set_item
      @item = @order.line_items.find(params[:id])
    end

    def set_order
      @order = Order.find(params[:order_id])
    end

    def line_item_params
      params.require(:order).permit(
        line_items_attributes: [
          :id, :item_id, :quantity, :_destroy
        ]
      ).fetch(:line_items_attributes, {}).deep_symbolize_keys
    end

    def load_form_data
      @catalog_items = Item.where(ownable: false, active: true).includes(:barcode).order(:name)
    end
end
