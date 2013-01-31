require 'test_helper'

class NetworkMembershipsControllerTest < ActionController::TestCase
  setup do
    @network_membership = network_memberships(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:network_memberships)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create network_membership" do
    assert_difference('NetworkMembership.count') do
      post :create, network_membership: {  }
    end

    assert_redirected_to network_membership_path(assigns(:network_membership))
  end

  test "should show network_membership" do
    get :show, id: @network_membership
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @network_membership
    assert_response :success
  end

  test "should update network_membership" do
    put :update, id: @network_membership, network_membership: {  }
    assert_redirected_to network_membership_path(assigns(:network_membership))
  end

  test "should destroy network_membership" do
    assert_difference('NetworkMembership.count', -1) do
      delete :destroy, id: @network_membership
    end

    assert_redirected_to network_memberships_path
  end
end
