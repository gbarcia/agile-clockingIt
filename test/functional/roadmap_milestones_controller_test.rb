require 'test_helper'

class RoadmapMilestonesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:roadmap_milestones)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create roadmap_milestone" do
    assert_difference('RoadmapMilestone.count') do
      post :create, :roadmap_milestone => { }
    end

    assert_redirected_to roadmap_milestone_path(assigns(:roadmap_milestone))
  end

  test "should show roadmap_milestone" do
    get :show, :id => roadmap_milestones(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => roadmap_milestones(:one).to_param
    assert_response :success
  end

  test "should update roadmap_milestone" do
    put :update, :id => roadmap_milestones(:one).to_param, :roadmap_milestone => { }
    assert_redirected_to roadmap_milestone_path(assigns(:roadmap_milestone))
  end

  test "should destroy roadmap_milestone" do
    assert_difference('RoadmapMilestone.count', -1) do
      delete :destroy, :id => roadmap_milestones(:one).to_param
    end

    assert_redirected_to roadmap_milestones_path
  end
end
