require "test_helper"

class SpecialDaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @special_day = special_days(:one)
  end

  test "should get index" do
    get special_days_url
    assert_response :success
  end

  test "should get new" do
    get new_special_day_url
    assert_response :success
  end

  test "should create special_day" do
    assert_difference("SpecialDay.count") do
      post special_days_url, params: { special_day: { day: @special_day.day } }
    end

    assert_redirected_to special_day_url(SpecialDay.last)
  end

  test "should show special_day" do
    get special_day_url(@special_day)
    assert_response :success
  end

  test "should get edit" do
    get edit_special_day_url(@special_day)
    assert_response :success
  end

  test "should update special_day" do
    patch special_day_url(@special_day), params: { special_day: { day: @special_day.day } }
    assert_redirected_to special_day_url(@special_day)
  end

  test "should destroy special_day" do
    assert_difference("SpecialDay.count", -1) do
      delete special_day_url(@special_day)
    end

    assert_redirected_to special_days_url
  end
end
