class Sessions::MagicLinksController < ApplicationController
  layout "sign_in"

  allow_unauthenticated_access only: %i[ show create ]

  def show
  end

  def create
     identity = MagicLink.transaction do
      magic_link = MagicLink.consume(params[:code])
      magic_link&.identity
    end

    if identity
      reset_session
      start_new_session_for identity
      redirect_to customers_path, notice: "You are signed in."
    else
      redirect_to new_session_path, alert: "That code is invalid or has expired. Request a new one and try again."
    end
  end
end
