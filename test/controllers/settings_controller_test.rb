require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "settings page is publicly accessible" do
    get settings_path
    assert_response :success
  end

  test "renders one card per available theme" do
    get settings_path
    assert_select ".theme-card", count: SettingsController::THEMES.size
  end
end
