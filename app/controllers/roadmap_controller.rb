class RoadmapController < ApplicationController
  def index
  end

  def recent
    if params[:id].nil?
      roadmap_project = current_user.projects.find :first
      project_id = roadmap_project.id
    else
      project_id = params[:id]
    end
    @milestones = RoadmapMilestone.find(:all, :conditions => ["date > ? and date < ? and project_id = ?", params[:start].to_time, params[:end].to_time, project_id])
    render :partial => 'roadmap/roadmap_json'
  end

end
