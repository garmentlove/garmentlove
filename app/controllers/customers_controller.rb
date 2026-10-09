class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update destroy ]

  # GET /customers or /customers.json
  def index
    @customers = Customer.all
  end

  # GET /customers/1 or /customers/1.json
  def show
  end

  # GET /customers/new
  def new
    @customer = Customer.new
    build_associations
  end

  # GET /customers/1/edit
  def edit
    build_associations
  end

  # POST /customers or /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: "Customer was successfully created." }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @customer.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /customers/1 or /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: "Customer was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @customer.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /customers/1 or /customers/1.json
  def destroy
    @customer.destroy!

    respond_to do |format|
      format.html { redirect_to customers_path, notice: "Customer was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params.expect(:id))
    end

    def build_associations
      @customer.build_address unless @customer.address.present?
      @customer.build_cellphone unless @customer.cellphone.present?
      @customer.build_email unless @customer.email.present?
    end

    # Only allow a list of trusted parameters through.
    def customer_params
        params.expect(customer: [
          :first_name,
          :last_name,
          :skip_unique_name_validation,
          :customer_type,
          address_attributes: address_params,
          billing_address_attributes: address_params,
          cellphone_attributes: telephone_params,
          homephone_attributes: telephone_params,
          email_attributes: email_address_params,
          secondary_email: email_address_params
        ])
    end

    def address_params
      [ :street, :street2, :city, :state, :zip, :country, :_destroy  ]
    end

    def telephone_params
      [ :number, :_destroy ]
    end

    def email_address_params
      [ :address, :_destroy ]
    end
end
