class App::SessionsController < App::BaseController
  allow_unauthenticated_access only: %i[ new create ]

  def new
  end

  def create
    if identity = Identity.find_for_authentication(sign_in_param, with: :customer)
      sign_in identity
    else
      redirect_to new_app_session_path, alert: "No account found."
    end
  end

  def destroy
    terminate_session
    redirect_to new_app_session_path, status: :see_other
  end

  private
    def sign_in_param
      params.expect(:sign_in)
    end

    def sign_in(identity)
      token = identity.signed_id(purpose: :sign_in)
      redirect_to app_session_token_path(token), notice: "Please complete your sign in."
    end
end
