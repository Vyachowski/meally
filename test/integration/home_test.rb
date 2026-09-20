require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  # Ticket 02 adds authentication, at which point an unauthenticated GET /
  # redirects to the sign-in form instead. This test has to sign in first then.
  test "the home page renders" do
    get root_url

    assert_response :success
    assert_select "h1", "Meally"
  end
end
