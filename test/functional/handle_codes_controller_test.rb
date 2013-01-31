require 'test_helper'

class HandleCodesControllerTest < ActionController::TestCase
  setup do
    @handle_code = handle_codes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:handle_codes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create handle_code" do
    assert_difference('HandleCode.count') do
      post :create, handle_code: {  }
    end

    assert_redirected_to handle_code_path(assigns(:handle_code))
  end

  test "should show handle_code" do
    get :show, id: @handle_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @handle_code
    assert_response :success
  end

  test "should update handle_code" do
    put :update, id: @handle_code, handle_code: {  }
    assert_redirected_to handle_code_path(assigns(:handle_code))
  end

  test "should destroy handle_code" do
    assert_difference('HandleCode.count', -1) do
      delete :destroy, id: @handle_code
    end

    assert_redirected_to handle_codes_path
  end
end
