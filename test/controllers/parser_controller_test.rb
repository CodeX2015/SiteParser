require 'test_helper'

class ParserControllerTest < ActionController::TestCase
  test "should get yandex" do
    get :yandex
    assert_response :success
  end

end
