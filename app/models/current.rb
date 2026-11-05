class Current < ActiveSupport::CurrentAttributes
  attribute :session, :identity
  attribute :http_method, :request_id, :user_agent, :ip_address, :referrer
  attribute :authentication_type, default: "session"

  def session=(value)
    super(value)

    if value.present?
      self.identity = session.identity
    end
  end
end
