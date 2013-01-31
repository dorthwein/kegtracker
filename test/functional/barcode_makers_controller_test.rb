require 'test_helper'

class BarcodeMakersControllerTest < ActionController::TestCase
  setup do
    @barcode_maker = barcode_makers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:barcode_makers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create barcode_maker" do
    assert_difference('BarcodeMaker.count') do
      post :create, barcode_maker: {  }
    end

    assert_redirected_to barcode_maker_path(assigns(:barcode_maker))
  end

  test "should show barcode_maker" do
    get :show, id: @barcode_maker
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @barcode_maker
    assert_response :success
  end

  test "should update barcode_maker" do
    put :update, id: @barcode_maker, barcode_maker: {  }
    assert_redirected_to barcode_maker_path(assigns(:barcode_maker))
  end

  test "should destroy barcode_maker" do
    assert_difference('BarcodeMaker.count', -1) do
      delete :destroy, id: @barcode_maker
    end

    assert_redirected_to barcode_makers_path
  end
end
