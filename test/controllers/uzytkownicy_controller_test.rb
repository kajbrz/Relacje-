require 'test_helper'

class UzytkownicyControllerTest < ActionController::TestCase
  test "should get logowanie" do
    get :logowanie
    assert_response :success
  end

  test "should get rejestracja" do
    get :rejestracja
    assert_response :success
  end

end
