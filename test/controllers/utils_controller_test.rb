require "test_helper"

class UtilsControllerTest < ActionDispatch::IntegrationTest
  test "should get get_schedule" do
    get utils_get_schedule_url
    assert_response :success
  end
end
