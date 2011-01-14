# Placeholder for the upcoming API
#
require 'rexml/document'
class ApiController < ApplicationController

  # Return a list of Projects
  def get_projects
    projects = Project.find(:all, :conditions => ["projects.company_id=1"], :include => [ :customer])
    render :xml => projects.to_xml(:include => [:customer, :milestones, :tasks])
  end

  # Return a list of iterations for a project
  def get_iterations
    project = Project.find params[:id]
    iterations = project.milestones
    render :xml => iterations.to_xml
  end

  # Return a list of user stories for iteration
  def get_user_stories
      iteration = Milestone.find params[:id]
      user_s = iteration.tasks
      render :xml => user_s.to_xml
  end

  # Return a list of Tasks for a Project
  def project_financial_res
    doc = REXML::Document.new
    prj = Project.find params[:id]
    project = doc.add_element 'project_financial_res'
    project_id = project.add_element 'project_id'
    project_id.add_text prj.id.to_s
    currency = project.add_element 'prj_currency'
    currency.add_text prj.currency_iso_code
    #managements indicators
    estimate_cost = project.add_element 'estimate_cost'
    estimate_cost.add_text prj.get_estimate_cost.to_s
    real_cost = project.add_element 'real_cost'
    real_cost.add_text prj.get_real_cost.to_s
    balance = project.add_element 'balance'
    balance.add_text prj.get_balance_presentation + ' %'
    benefist = project.add_element 'benefist'
    benefist.add_text prj.get_benefist.to_s
    cost_benefist = project.add_element 'cost-benefist'
    cost_benefist.add_text prj.get_cost_benefis_ratio.to_s
    present_value = project.add_element 'present-value'
    present_value.add_text prj.get_npv.to_s
    earned_value = project.add_element 'earned-value'
    earned_value.add_text prj.get_earned_value.to_s
    cpi = project.add_element 'cpi'
    cpi.add_text prj.get_cpi.to_s
    spi = project.add_element 'spi'
    spi.add_text prj.get_spi.to_s
    roi = project.add_element 'roi'
    roi.add_text(prj.get_roi.to_s)

    render :xml => doc
  end

  def project_points_res
    doc = REXML::Document.new
    prj = Project.find params[:id]
    project = doc.add_element 'project_points_res'

    estimate = project.add_element 'estimate'
    estimate.add_text prj.total_points.to_s
    real = project.add_element 'real'
    real.add_text prj.get_real_points.to_s
    points_per_hour = project.add_element 'points-per-hour'
    points_per_hour.add_text prj.average_points_per_hour.to_s
    planed_business_value = project.add_element 'planed-business-value'
    planed_business_value.add_text prj.total_business_value.to_s
    real_business_value = project.add_element 'real-business-value'
    real_business_value.add_text prj.real_business_value.to_s
    cost_benefist = project.add_element 'cost-benefist'
    cost_benefist.add_text prj.benefist_cost_points.to_s
    efectivity = project.add_element 'efectivity'
    efectivity.add_text prj.points_balance.to_s

    render :xml => doc
  end
end
