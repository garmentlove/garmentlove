class App::Sessions::TokensController < App::BaseController
  allow_unauthenticated_access

  def show
    identity = Identity.find_signed(params[:token], purpose: :sign_in)

    if identity
      start_new_session_for identity
      redirect_to app_profile_path, notice: "Signed in."
    else
      redirect_to new_session_path, alert: "Invaild token."
    end
  end
end
