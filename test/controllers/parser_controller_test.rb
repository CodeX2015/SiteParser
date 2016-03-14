require 'test_helper'

class ParserControllerTest < ActionController::TestCase
  test "should get fl" do
    get :fl
    assert_response :success
  end

end
