class App::AddressesController < App::BaseController
  before_action :set_customer
  before_action :set_address, only: %i[ show edit update destroy ]

  track :address, only: %i[ create update ]

  # GET /app/addresses
  def index
    @addresses = @customer.addresses
  end

  # GET /app/addresses/new
  def new
    @address = @customer.addresses.new

    check_for_avaliable_designations
  end

  # GET /app/addresses/1/edit
  def edit
  end

  # PATCH/PUT /app/addresses/1
  def update
    respond_to do |format|
      if @address.update(address_params)
        format.html { redirect_to app_addresses_path, notice: "You've successfully updated your address.", status: :see_other }
        format.json { render :show, status: :ok, location: @address }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @address.errors, status: :unprocessable_content }
      end
    end
  end

  def create
    @address = @customer.addresses.new(address_params)

    respond_to do |format|
      if @address.save
        format.html { redirect_to app_addresses_path, notice: "Address was successfully created." }
        format.json { render :show, status: :created, location: [ :app, @address ] }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @address.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /app/addresses/1 or /app/addresses/1.json
  def destroy
    @address.destroy!

    respond_to do |format|
      format.html { redirect_to app_addresses_path, notice: "Address was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_customer
      @customer = Current.identity.userable
    end

    def set_address
       @address = @customer.addresses.find(params[:id])
    end

    def address_params
      params.expect(address: [ :designation, :street, :street2, :city, :state, :zip, :country ])
    end

    def check_for_avaliable_designations
      if @customer.avaliable_address_designations.empty?
        redirect_to app_addresses_path, alert: "No available address slots left."
      end
    end
end
