class App::ProfilesController < App::BaseController
  before_action :set_customer

  track :customer, only: %i[ update ]

  # GET /app/profile or /app/profile.json
  def show
  end

  def edit
    build_associations
  end

  # PATCH/PUT /app/profile
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to app_profile_path, notice: "You've successfully updated your profile.", status: :see_other }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @customer.errors, status: :unprocessable_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Current.identity.userable
    end

    def build_associations
      @customer.build_cellphone unless @customer.cellphone.present?
      @customer.build_email unless @customer.email.present?
    end

    # Only allow a list of trusted parameters through.
    def customer_params
        params.expect(customer: [
          :first_name,
          :last_name,
          address_attributes: address_params,
          billing_address_attributes: address_params,
          cellphone_attributes: telephone_params,
          homephone_attributes: telephone_params,
          email_attributes: email_address_params,
          secondary_email: email_address_params
        ])
    end

    def address_params
      [ :id, :street, :street2, :city, :state, :zip, :country, :_destroy  ]
    end

    def telephone_params
      [ :id, :number, :_destroy ]
    end

    def email_address_params
      [ :id, :address, :_destroy ]
    end
end
