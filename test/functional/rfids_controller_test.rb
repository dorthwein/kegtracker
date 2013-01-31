require 'test_helper'

class RfidsControllerTest < ActionController::TestCase
  setup do
    @rfid = rfids(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rfids)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rfid" do
    assert_difference('Rfid.count') do
      post :create, rfid: {  }
    end

    assert_redirected_to rfid_path(assigns(:rfid))
  end

  test "should show rfid" do
    get :show, id: @rfid
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rfid
    assert_response :success
  end

  test "should update rfid" do
    put :update, id: @rfid, rfid: {  }
    assert_redirected_to rfid_path(assigns(:rfid))
  end

  test "should destroy rfid" do
    assert_difference('Rfid.count', -1) do
      delete :destroy, id: @rfid
    end

    assert_redirected_to rfids_path
  end
end
