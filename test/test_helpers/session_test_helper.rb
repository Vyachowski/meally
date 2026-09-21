module SessionTestHelper
  # The fixture stores the bcrypt digest of this; a test that posts the
  # sign-in form needs the password itself. One definition, so the two
  # cannot drift apart.
  TEST_PASSWORD = "a-test-only-password"

  def sign_in_as(user)
    Current.session = user.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = Current.session.id
      cookies["session_id"] = cookie_jar[:session_id]
    end
  end

  def sign_out
    Current.session&.destroy!
    cookies.delete("session_id")
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include SessionTestHelper
end
