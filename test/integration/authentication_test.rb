require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  setup { @user = users(:cook) }

  test "signing in with the correct password reaches the home page" do
    sign_in_with password: SessionTestHelper::TEST_PASSWORD

    assert_redirected_to root_url
    follow_redirect!
    assert_select "h1", "Meally"
  end

  test "signing in with a wrong password reports it and starts no session" do
    sign_in_with password: "wrong"

    assert_redirected_to new_session_url
    assert_empty Session.all
    assert_empty cookies[:session_id].to_s

    follow_redirect!
    assert_select "p.flash.alert"
  end

  test "an unauthenticated request to any page lands on the sign-in form" do
    get root_url

    assert_redirected_to new_session_url
    follow_redirect!
    assert_select "form[action=?]", session_path do
      assert_select "input[type=password]"
    end
  end

  test "after signing in, the originally requested page is restored" do
    # The home page is the only page there is, so a query string stands in for
    # a deeper link: the point is that the stored URL wins over root_url.
    requested = root_url(from: "a-deep-link")
    get requested
    assert_redirected_to new_session_url

    sign_in_with password: SessionTestHelper::TEST_PASSWORD

    assert_redirected_to requested
  end

  test "a sign-out control ends the session and returns to the sign-in form" do
    sign_in_as @user

    get root_url
    assert_select "form[action=?][method=post]", session_path do
      assert_select "input[name=_method][value=delete]"
    end

    delete session_url

    assert_redirected_to new_session_url
    assert_empty @user.sessions.reload
    assert_empty cookies[:session_id].to_s

    get root_url
    assert_redirected_to new_session_url
  end

  test "the paths the session controller does not answer are not routed" do
    # Unnarrowed, `resource :session` routes these at actions that do not
    # exist, which is a 500 rather than a 404. The deleted password reset is
    # here for the same reason.
    %w[ /session /session/edit /passwords/new ].each do |path|
      get path
      assert_response :not_found, "GET #{path} should not be routed"
    end

    patch "/session"
    assert_response :not_found
  end

  private
    def sign_in_with(password:)
      post session_url, params: { email_address: @user.email_address, password: password }
    end
end
