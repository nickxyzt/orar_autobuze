require "application_system_test_case"

class SpecialDaysTest < ApplicationSystemTestCase
  setup do
    @special_day = special_days(:one)
  end

  test "visiting the index" do
    visit special_days_url
    assert_selector "h1", text: "Special days"
  end

  test "should create special day" do
    visit special_days_url
    click_on "New special day"

    fill_in "Day", with: @special_day.day
    click_on "Create Special day"

    assert_text "Special day was successfully created"
    click_on "Back"
  end

  test "should update Special day" do
    visit special_day_url(@special_day)
    click_on "Edit this special day", match: :first

    fill_in "Day", with: @special_day.day
    click_on "Update Special day"

    assert_text "Special day was successfully updated"
    click_on "Back"
  end

  test "should destroy Special day" do
    visit special_day_url(@special_day)
    click_on "Destroy this special day", match: :first

    assert_text "Special day was successfully destroyed"
  end
end
