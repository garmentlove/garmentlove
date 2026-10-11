module Authentication::ViaMagicLink
  extend ActiveSupport::Concern

  private
    def set_pending_authentication_token(magic_link)
      cookies[:pending_authentication_token] = {
        value: pending_authentication_token_verifier.generate(
          magic_link.identity.to_gid.to_s,
          expires_at: magic_link.expires_at),
        httponly: true,
        same_site: :lax,
        expires: magic_link.expires_at
      }
    end

    def identity_pending_authentication
      pending_authentication_token_verifier.verified(pending_authentication_token)
    end

    def pending_authentication_token_verifier
      Rails.application.message_verifier(:pending_authentication)
    end

    def pending_authentication_token
      cookies[:pending_authentication_token]
    end

    def clear_pending_authentication_token
      cookies.delete(:pending_authentication_token)
    end
end
