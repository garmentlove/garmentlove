class SessionsController < ApplicationController
  layout "sign_in"

  allow_unauthenticated_access only: %i[ new create ]

  def new
  end

  def create
    email_address = params[:sign_in].to_s.strip.downcase
    identity = Identity.find_for_authentication(email_address, with: :user) if email_address.present?

    if identity
      magic_link = identity.magic_links.create!(purpose: :sign_in)
      MagicLinkMailer.with(code: magic_link.code, email_address: identity.email).sign_in.deliver_later
    end

    redirect_to session_magic_link_path, notice: "If an account exists for that email, a sign-in code is on its way."
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
