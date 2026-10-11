class Sessions::MagicLinksController < ApplicationController
  layout "sign_in"

  allow_unauthenticated_access only: %i[ show create ]
  rate_limit to: 10, within: 15.minutes, only: :create, with: :rate_limit_exceeded
  before_action :ensure_that_identity_pending_authentication_exists, only: :show

  def show
    @pending = identity_pending_authentication
  end

  def create
    if magic_link = MagicLink.consume(code)
      authenticate(magic_link)
    else
      invalid_code
    end
  end

  private
    def code
      params.expect(:code)
    end

    def authenticate(magic_link)
      if ActiveSupport::SecurityUtils.secure_compare(identity_pending_authentication || "", magic_link.identity.to_gid.to_s)
        sign_in(magic_link)
      else
        identity_id_mismatch
      end
    end

    def sign_in(magic_link)
      clear_pending_authentication_token
      start_new_session_for magic_link.identity

      respond_to do |format|
        format.html { redirect_to customers_path, notice: "You are signed in." }
        format.json { render json: { session_token: session_token } }
      end
    end

    def ensure_that_identity_pending_authentication_exists
      unless identity_pending_authentication.present?
        alert_message = "Enter your username, email address, or phone number to sign in."
        respond_to do |format|
          format.html { redirect_to new_session_path, alert: alert_message }
          format.json { render json: { message: alert_message }, status: :unauthorized }
        end
      end
    end

    def identity_id_mismatch
      clear_pending_authentication_token
      alert_message = "Something went wrong. Please try again."

      respond_to do |format|
        format.html { redirect_to new_session_path, alert: alert_message }
        format.json { render json: { message: alert_message }, status: :unauthorized }
      end
    end

    def invalid_code
      respond_to do |format|
        format.html { redirect_to session_magic_link_path, alert: "Try another code." }
        format.json { render json: { message: "Try another code." }, status: :unauthorized }
      end
    end
end
