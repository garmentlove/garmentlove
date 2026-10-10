class MagicLinkMailer < ApplicationMailer
  def sign_in
    @code = params[:code]
    mail(to: params[:email_address], subject: "Your GarmentLove sign-in code")
  end
end
