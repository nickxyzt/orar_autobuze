require "test_helper"

class StopsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get stops_new_url
    assert_response :success
  end

  test "should get create" do
    get stops_create_url
    assert_response :success
  end
end
