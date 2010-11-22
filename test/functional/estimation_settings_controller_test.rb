require 'test_helper'

class EstimationSettingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:estimation_settings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create estimation_setting" do
    assert_difference('EstimationSetting.count') do
      post :create, :estimation_setting => { }
    end

    assert_redirected_to estimation_setting_path(assigns(:estimation_setting))
  end

  test "should show estimation_setting" do
    get :show, :id => estimation_settings(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => estimation_settings(:one).to_param
    assert_response :success
  end

  test "should update estimation_setting" do
    put :update, :id => estimation_settings(:one).to_param, :estimation_setting => { }
    assert_redirected_to estimation_setting_path(assigns(:estimation_setting))
  end

  test "should destroy estimation_setting" do
    assert_difference('EstimationSetting.count', -1) do
      delete :destroy, :id => estimation_settings(:one).to_param
    end

    assert_redirected_to estimation_settings_path
  end
end
