class SessionsController < ApplicationController
  layout "sign_in"

  allow_unauthenticated_access only: %i[ new create ]

  def new
  end

  def create
    if identity = Identity.find_for_authentication(sign_in_param, with: :user)
      sign_in identity
    else
      redirect_to new_session_path, alert: "No account found."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private
    def sign_in_param
      params.expect(:sign_in)
    end

    def sign_in(identity)
      magic_link = identity.send_magic_link(purpose: :sign_in)
      set_pending_authentication_token(magic_link)

      respond_to do |format|
        format.html { redirect_to session_magic_link_path, notice: "A sign-in code is on its way." }
      end
    end
end
