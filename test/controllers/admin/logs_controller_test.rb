require "test_helper"

class Admin::LogsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_logs_index_url
    assert_response :success
  end
end
