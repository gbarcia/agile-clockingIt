class RoadmapController < ApplicationController
  def index
    if !params[:id].nil?
      session[:id_prj] = params[:id]
      project_id = params[:id]
    else
      roadmap_project = current_user.projects.find :first
      project_id = roadmap_project.id
      session[:id_prj] = project_id
    end
    @project = Project.find project_id
  end

  def recent
    if session[:id_prj].nil?
      roadmap_project = current_user.projects.find :first
      project_id = roadmap_project.id
    else
      project_id = session[:id_prj]
    end
    @milestones = RoadmapMilestone.find(:all, :conditions => ["date > ? and date < ? and project_id = ?", params[:start].to_time, params[:end].to_time, project_id])
    @iterations =  Milestone.find(:all, :conditions => ["due_at > ? and init_date < ? and project_id = ?",params[:start].to_time, params[:end].to_time,project_id])
    render :partial => 'roadmap/roadmap_json'
  end

end
