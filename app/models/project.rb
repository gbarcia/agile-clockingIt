# A logical grouping of milestones and tasks, belonging to a Customer / Client

class Project < ActiveRecord::Base
  belongs_to    :company
  belongs_to    :customer
  belongs_to    :owner, :class_name => "User", :foreign_key => "user_id"

  has_many      :users, :through => :project_permissions
  has_many      :project_permissions, :dependent => :destroy
  has_many      :pages, :as => :notable, :class_name => "Page", :order => "id desc", :dependent => :destroy
  has_many      :tasks
  has_many      :sheets
  has_many      :work_logs, :dependent => :destroy
  has_many      :project_files, :dependent => :destroy
  has_many      :project_folders, :dependent => :destroy
  has_many      :milestones, :dependent => :destroy, :order => "due_at asc, lower(name) asc"
  has_many      :forums, :dependent => :destroy
  has_many      :roadmap_milestones, :dependent => :nullify
  has_one       :estimation_setting, :dependent => :destroy

  validates_length_of           :name,  :maximum=>200
  validates_presence_of         :name
  validates_presence_of         :customer
  after_create { |r|
    if r.create_forum && r.company.show_forum
      f = Forum.new
      f.company_id = r.company_id
      f.project_id = r.id
      f.name = r.full_name
      f.save
    end
  }

  def full_name
    "#{customer.name} / #{name}"
  end

  def to_s
    name
  end

  def to_css_name
    "#{self.name.underscore.dasherize.gsub(/[ \."',]/,'-')} #{self.customer.name.underscore.dasherize.gsub(/[ \.'",]/,'-')}"
  end

  def total_estimate
    tasks.sum(:duration).to_i
  end

  def work_done
    tasks.sum(:worked_minutes).to_i
  end

  def overtime
    tasks.sum('worked_minutes - duration', :conditions => "worked_minutes > duration").to_i
  end

  def percent_desviation
    total_points = 0
    closed_points = 0
    self.milestones.each do |i|
      if i.get_real_cost > 0
        total_points += i.total_points
        closed_points += i.total_points_execute
      end
    end
    total = 100.to_f - ((closed_points.to_f/total_points.to_f) * 100)
    if !total.nan?
      return (total * 10**2).round.to_f / 10**2 #round two decimals
    else
      return 0
    end
  end

  def total_tasks_count
    if self.total_tasks.nil?
      self.total_tasks = tasks.count
      self.save
    end
    total_tasks
  end

  def end_date_estimate
    end_date = self.created_at
    self.milestones.each do |i|
      end_date = i.due_date > end_date ? i.due_date : end_date
    end
    return end_date
  end

  def variaton_schedule
    return (self.get_earned_value - self.get_estimate_cost)
  end

  def variation_cost
    return (self.get_earned_value - self.get_real_cost)
  end

  def open_tasks_count
    if self.open_tasks.nil?
      self.open_tasks = tasks.count(:conditions => ["completed_at IS NULL"])
      self.save
    end
    open_tasks
  end

  def total_milestones_count
    if self.total_milestones.nil?
      self.total_milestones = milestones.count
      self.save
    end
    total_milestones
  end

  def open_milestones_count
    if self.open_milestones.nil?
      self.open_milestones = milestones.count(:conditions => ["completed_at IS NULL"])
      self.save
    end
    open_milestones
  end

  def total_points
    total_points = 0
    self.milestones.each do |iteration|
      total_points += iteration.total_points
    end
    return (total_points * 10**2).round.to_f / 10**2 #round two decimals
  end

  def total_points_execute
    total_points = 0
    self.milestones.each do |iteration|
      total_points += iteration.total_points_execute
    end
    return (total_points * 10**2).round.to_f / 10**2
  end

  def total_business_value
    total = 0
    self.milestones.each do |iteration|
      total += iteration.total_business_value
    end
    return total
  end
  
  def real_business_value
    total = 0
    self.milestones.each do |iteration|
      total += iteration.real_business_value
    end
    return total
  end

  def points_balance
    total_points_planed = total_points
    total_points_exe = total_points_execute
    if total_points_exe > 0
      result = total_points_exe.to_f / total_points_planed.to_f
      return (result * 10**2).round.to_f / 10**2 #round two decimals
    else
      return 0
    end
  end

  def average_points_per_hour
    points_per_hour_list = Array.new
    self.milestones.each do |iteration|
      points_per_hour_list << iteration.points_per_hour_iteration
    end
    average_result = Statistics.mean(points_per_hour_list)
    return average_result
  end
  
  def desviation_points_per_hour
    points_per_hour_list = Array.new
    self.milestones.each do |iteration|
      points_per_hour_list << iteration.points_per_hour_iteration
    end
    result = Statistics.standard_desviation(points_per_hour_list)
    return result
  end

  def benefist_cost_points
    total_points = total_points_execute
    total_business_value = real_business_value
    if total_points > 0
      result = total_business_value.to_f / total_points.to_f
       return ((result * 10**2).round.to_f / 10**2).to_s + ":1" #round two decimals
    else
      return "0:1"
    end
  end

  ###
  # Updates the critical, normal and low counts for this project.
  # Also updates open and total tasks.
  ###
  def update_project_stats
    self.critical_count = tasks.count(:conditions => { "task_property_values.property_value_id" => company.critical_values },
      :include => :task_property_values)
    self.normal_count = tasks.count(:conditions => { "task_property_values.property_value_id" => company.normal_values },
      :include => :task_property_values)
    self.low_count = tasks.count(:conditions => { "task_property_values.property_value_id" => company.low_values },
      :include => :task_property_values)

    self.open_tasks = nil
    self.total_tasks = nil
  end

  #return the estimate global cost of the project
  def get_estimate_cost
    total_estimate_cost_project = 0.0
    iterations = self.milestones
    iterations.each do |iteration|
      total_estimate_cost_project += iteration.get_estimate_cost
    end
    if total_estimate_cost_project.nan?
      total_estimate_cost_project = 0.0
    end
    return (total_estimate_cost_project * 10**2).round.to_f / 10**2 #round two decimals
  end

  #the real cost of the project
  def get_real_cost
    total_real_cost_project = 0.0
    iterations = self.milestones
    iterations.each do |iteration|
      total_real_cost_project += iteration.get_real_cost
    end
    if total_real_cost_project.nan?
      total_real_cost_project = 0.0
    end
    return (total_real_cost_project * 10**2).round.to_f / 10**2 #round two decimals
  end

  #the benefist of the project
  def get_benefist
    real_cost = get_real_cost * (1 - (self.tir_per_hour/100)) # add the roi per hour of company
    return (get_estimate_cost - real_cost)
  end

  #the earned value of the project
  def get_earned_value
    total_ev = 0.0
    iterations = self.milestones
    iterations.each do |iteration|
      total_ev += iteration.get_earned_value
    end
    if total_ev.nan? || total_ev.infinite?
      total_ev = 0.0
    end
    return (total_ev * 10**2).round.to_f / 10**2 #round two decimals
  end

  def get_real_points
    total_ev = 0.0
    iterations = self.milestones
    iterations.each do |iteration|
      total_ev += iteration.get_real_points
    end
    if total_ev.nan? || total_ev.infinite?
      total_ev = 0.0
    end
    return (total_ev * 10**2).round.to_f / 10**2
  end

  #return the cost/benefist ratio
  def get_cost_benefis_ratio
    benefist = get_benefist
    cb = benefist / get_real_cost rescue 0
    if cb.nan? || cb.infinite?
      cb = 0.0
    end
    return (cb * 10**1).round.to_f / 10**1 #round one decimals
  end

  # get the balance of estimate cost and real cost in percent in project
  def get_balance
    balance = (get_benefist/get_estimate_cost) * 100 rescue 0
    if balance.nan? || balance.infinite?
      balance = 0.0
    end
    return balance
  end

  #get the balance in presentation for user interface
  def get_balance_presentation
    balance_amount = get_balance
    word = 'Profit '
    if balance_amount < 0
      word = 'Deficit '
      balance_amount = balance_amount * -1
    else if balance_amount == 0
        word = ""
      end
    end
    return word + balance_amount.to_i.to_s
  end

  #return the roi of the project
  def get_roi
    estimate_cost = get_estimate_cost
    real_cost = get_real_cost
    benefist = get_benefist
    roi = ((benefist)/ real_cost) * 100 rescue 0
    if roi.nan? || roi.infinite?
      roi = 0.0
    end
    return (roi * 10**2).round.to_f / 10**2 #round two decimals
  end

  #return de net present value in one year projection of the global project
  def get_npv
    benefist = get_benefist
    npv = benefist / (1 + (self.inflation_rate/100))
    if npv.nan? || npv.infinite?
      npv = 0.0
    end
    return (npv * 10**2).round.to_f / 10**2 #round two decimals
  end

  # return a cost program index of project
  def get_cpi
    earned_value = get_earned_value
    real_cost = get_real_cost
    cpi = earned_value / real_cost
    if cpi.nan? || cpi.infinite?
      cpi = 0.0
    end
    return (cpi * 10**2).round.to_f / 10**2 #round two decimals
  end

  #return a plan program index of project
  def get_spi
    earned_value = get_earned_value
    estimate_cost = get_estimate_cost
    spi = earned_value / estimate_cost
    if spi.nan? || spi.infinite?
      spi = 0.0
    end
    return (spi * 10**2).round.to_f / 10**2 #round two decimals
  end

  # return iterations before a paramater date
  def get_iterations_before (date_before)
    iterations = Milestone.find(:all, :conditions => ["due_at < ?",date_before])
    return iterations
  end

   # return first iteration before a paramater date
  def get_iteration_before (date_before)
    iterations = Milestone.find(:all, :conditions => ["due_at < ?",date_before], :order => "init_date DESC")
    return iterations[0]
  end

  #boolean return if currency for project if change
  def currency_change? (new_currency_iso_code)
    return (new_currency_iso_code != self.currency_iso_code)
  end
end


# == Schema Information
#
# Table name: projects
#
#  id               :integer(4)      not null, primary key
#  name             :string(200)     default(""), not null
#  user_id          :integer(4)      default(0), not null
#  company_id       :integer(4)      default(0), not null
#  customer_id      :integer(4)      default(0), not null
#  created_at       :datetime
#  updated_at       :datetime
#  completed_at     :datetime
#  critical_count   :integer(4)      default(0)
#  normal_count     :integer(4)      default(0)
#  low_count        :integer(4)      default(0)
#  description      :text
#  create_forum     :boolean(1)      default(TRUE)
#  open_tasks       :integer(4)
#  total_tasks      :integer(4)
#  total_milestones :integer(4)
#  open_milestones  :integer(4)
#  leader_id        :integer(4)
#  currency_iso_code:string
#
# Indexes
#
#  projects_company_id_index   (company_id)
#  projects_customer_id_index  (customer_id)
#  fk_projects_user_id         (user_id)
#  fk_projects_leader_id       (user_id)
#

