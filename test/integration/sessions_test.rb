require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "requests a code for an existing user and signs in with it" do
    user = create_user

    assert_enqueued_emails 1 do
      post session_path, params: { email_address: user.email.address.upcase }
    end

    magic_link = user.identity.magic_links.last
    assert_equal "sign_in", magic_link.purpose
    assert_equal MagicLink::CODE_LENGTH, magic_link.code.length
    assert_in_delta MagicLink::EXPIRATION_TIME.to_f, magic_link.expires_at - Time.current, 1.0

    post verify_session_path, params: { code: magic_link.code }

    assert_redirected_to customers_path
    assert_equal 1, user.identity.sessions.count
    assert_not MagicLink.exists?(magic_link.id)
    get customers_path
    assert_response :success

    delete session_path

    assert_redirected_to new_session_path
    assert_empty user.identity.sessions
  end

  test "does not disclose whether an email address has an account" do
    assert_no_enqueued_emails do
      post session_path, params: { email_address: "unknown@example.com" }
    end

    assert_redirected_to new_session_path
    assert_equal "If an account exists for that email, a sign-in code is on its way.", flash[:notice]
  end

  test "rejects an invalid code" do
    post verify_session_path, params: { code: "invalid" }

    assert_response :unprocessable_content
    assert_equal "That code is invalid or has expired. Request a new one and try again.", flash[:alert]
    assert_empty Session.all
  end

  test "rejects an expired code" do
    user = create_user
    magic_link = user.identity.magic_links.create!(purpose: :sign_in)
    magic_link.update!(expires_at: 1.minute.ago)

    post verify_session_path, params: { code: magic_link.code }

    assert_response :unprocessable_content
    assert_empty user.identity.sessions
    assert MagicLink.exists?(magic_link.id)
  end

  test "rejects a sign-up code for sign-in" do
    user = create_user
    magic_link = user.identity.magic_links.create!(purpose: :sign_up)

    post verify_session_path, params: { code: magic_link.code }

    assert_response :unprocessable_content
    assert_empty user.identity.sessions
    assert MagicLink.exists?(magic_link.id)
  end

  test "redirects unauthenticated requests to the sign-in page" do
    get customers_path

    assert_redirected_to new_session_path
  end

  private
    def create_user
      User.create!(
        username: "user-#{SecureRandom.hex(6)}",
        email: "user-#{SecureRandom.hex(6)}@example.com"
      )
    end
end
