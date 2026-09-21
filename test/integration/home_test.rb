require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  test "the home page renders for a signed-in user" do
    sign_in_as users(:cook)

    get root_url

    assert_response :success
    assert_select "h1", "Meally"
  end
end
