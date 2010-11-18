require 'simile_timeline'
# Logical grouping of tasks from one project.
#
# Can have a due date, and be completed

class Milestone < ActiveRecord::Base
  belongs_to :company
  belongs_to :project
  belongs_to :user
  has_many :tasks, :dependent => :nullify

  validate :validate_dates

  after_save { |r|
    r.project.total_milestones = nil
    r.project.open_milestones = nil
    r.project.save
  }

  def percent_complete
    return 0.0 if total_tasks == 0
    return (completed_tasks.to_f / total_tasks.to_f) * 100.0
  end

  def complete?
    (self.completed_tasks == self.total_tasks) || (!self.completed_at.nil?)
  end

  def description_presentation
    result = "<p>ROI: "
    result << get_roi.to_s + " %</p><p>"
    result << self.description + "<p>"
  end
  
  def escape_twice(attr)
    h(String.new(h(attr)))
  end
  def to_tip(options = { })
    balance = get_balance
    res = "<table cellpadding=0 cellspacing=0>"
    res << "<tr><th>#{_('Name')}</th><td> #{escape_twice(self.name)}</td></tr>"
    res << "<tr><th>#{_('Begin Date')}</th><td> #{options[:user].tz.utc_to_local(init_date).strftime_localized("%A, %d %B %Y")}</td></tr>" unless self.init_date.nil?
    res << "<tr><th>#{_('Due Date')}</th><td> #{options[:user].tz.utc_to_local(due_at).strftime_localized("%A, %d %B %Y")}</td></tr>" unless self.due_at.nil?
    res << "<tr><th>#{_('Project')}</th><td> #{escape_twice(self.project.name)}</td></tr>"
    res << "<tr><th>#{_('Client')}</th><td> #{escape_twice(self.project.customer.name)}</td></tr>"
    res << "<tr><th>#{_('Budget')}</th><td> #{escape_twice(self.get_estimate_cost) << ' ' << get_project_currency(self.project_id) }</td></tr>" unless self.budget.nil?
    res << "<tr><th>#{_('Real Cost')}</th><td> #{escape_twice(self.get_real_cost) << ' ' << get_project_currency(self.project_id) }</td></tr>" unless self.budget.nil?
    res << "<tr><th>#{_('EV')}</th><td> #{escape_twice(self.get_earned_value) << ' ' << get_project_currency(self.project_id) }</td></tr>" unless self.budget.nil?
    res << "<tr><th>" 
    if balance < 0
      res <<  "<div style = 'color:red'>"
    end
    res << "#{_('Balance')}</th><td> #{escape_twice(self.get_balance_presentation) << ' ' << '%' }</td></tr>" unless self.budget.nil?
    if balance < 0
      res << "</div>"
    end
    res << "<tr><th>#{_('ROI')}</th><td> #{escape_twice(self.get_roi) << ' %' }</td></tr>" unless self.budget.nil?
    res << "<tr><th>#{_('B/CR')}</th><td> #{escape_twice(self.get_ratio_cost_benefist) << ':1' }</td></tr>" unless self.budget.nil?
    res << "<tr><th>#{_('Owner')}</th><td> #{escape_twice(self.user.name)}</td></tr>" unless self.user.nil?
    res << "<tr><th>#{_('Progress')}</th><td> #{self.completed_tasks.to_i} / #{self.total_tasks.to_i} #{_('Complete')}</td></tr>"
    res << "<tr><th>#{_('Description')}</th><td class=\"tip_description\">#{escape_twice(self.description_wrapped).gsub(/\n/, '<br/>').gsub(/\"/,'&quot;')}</td></tr>" unless self.description.blank?
    res << "</table>"
    res.gsub(/\"/,'&quot;')
  end

  def description_wrapped
    unless description.blank?
      truncate( word_wrap(self.description, :line_width => 80), :length => 1000)
    else
      nil
    end
  end
  # get the estimate cost of iteration by adding user stories for iteration
  def get_estimate_cost
    if self.id
      total_cost = 0.0
      user_stories = self.tasks
      user_stories.each do |user_story|
        total_cost += ((user_story.duration / 60.0) * self.project.cost_per_hour) rescue 0
      end
      return total_cost
    end
  end

  #return total points per iteration
  def total_points
    total_points = 0
    tasks = self.tasks
    tasks.each do |task|
      total_points += task.total_points
    end
    return total_points
  end

  # get the real cost of iteration by adding user stories worked minutos per iteration
  def get_real_cost
    if self.id
      total_cost = 0.0
      user_stories = self.tasks
      user_stories.each do |user_story|
        total_cost += ((user_story.worked_minutes / 60.0) * self.project.cost_per_hour) rescue 0
      end
      return total_cost
    end
  end

  #return benefist of milestone
  def get_benefist
    real_cost = get_real_cost * (1 - (self.project.tir_per_hour/100)) # add the roi per hour of company
    return (get_estimate_cost - real_cost)
  end

  # The earned value for iteration
  def get_earned_value
    if self.id
      total_ev = 0.0
      user_stories = self.tasks
      user_stories.each do |user_story|
        if user_story.closed?
          total_ev += ((user_story.duration / 60.0) * self.project.cost_per_hour) rescue 0
        end
      end
      return total_ev
    end
  end
  
  # get the balance of estimate cost and real cost in percent
  def get_balance
    estimate_cost = get_estimate_cost
    real_cost = get_real_cost
    balance = ((get_benefist)/estimate_cost) * 100 rescue 0
    if balance.nan?
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

  #return the roi of the itaration
  def get_roi
    estimate_cost = get_estimate_cost
    real_cost = get_real_cost
    benefist = get_benefist
    roi = (benefist/ real_cost) * 100 rescue 0
    if roi.nan? || roi.infinite?
      roi = 0.0
    end
    return (roi * 10**2).round.to_f / 10**2 #round two decimals
  end

  # return ratio of benefist/costr
  def get_ratio_cost_benefist
    benefist = get_benefist
    cb = benefist / get_real_cost
    if cb.nan? || cb.infinite?
      cb = 0.0
    end
    return (cb * 10**1).round.to_f / 10**1 #round one decimals
  end

  #return de net present value in one year projection
  def get_npv
    benefist = get_benefist
    npv = benefist / (1 + (self.project.inflation_rate/100))
    if npv.nan?
      npv = 0.0
    end
    return (npv * 10**2).round.to_f / 10**2 #round two decimals
  end

  # return a cost program index
  def get_cpi
    earned_value = get_earned_value
    real_cost = get_real_cost
    cpi = earned_value / real_cost
    if cpi.nan? || cpi.infinite?
      cpi = 0.0
    end
    return (cpi * 10**2).round.to_f / 10**2 #round two decimals
  end

  #return a plan program index
  def get_spi
    earned_value = get_earned_value
    estimate_cost = get_estimate_cost
    spi = earned_value / estimate_cost
    if spi.nan? || spi.infinite?
      spi = 0.0
    end
    return (spi * 10**2).round.to_f / 10**2 #round two decimals
  end

  def due_date
    unless @due_date
      if due_at.nil?
        last = self.tasks.collect{ |t| t.due_at.to_time.to_f if t.due_at }.compact.sort.last
        @due_date = Time.at(last).to_datetime if last
      else
        @due_date = due_at
      end
    end
    @due_date
  end

  def scheduled_date
    (self.scheduled? ? self.scheduled_at : self.due_at)
  end

  def worked_minutes
    if @minutes.nil?
      @minutes = WorkLog.sum('work_logs.duration', :joins => "INNER JOIN tasks ON tasks.milestone_id = #{self.id}", :conditions => ["work_logs.task_id = tasks.id AND tasks.completed_at IS NULL"] ) || 0
      @minutes /= 60
    end
    @minutes
  end

  def duration
    if @duration.nil?
      @duration = Task.sum(:duration, :conditions => ["tasks.milestone_id = ? AND tasks.completed_at IS NULL AND tasks.scheduled = ?", self.id, false]) || 0
      @duration += Task.sum(:scheduled_duration, :conditions => ["tasks.milestone_id = ? AND tasks.completed_at IS NULL AND tasks.scheduled = ?", self.id, true]) || 0
    end
    @duration
  end

  def update_counts
    self.completed_tasks = Task.count( :conditions => ["milestone_id = ? AND completed_at is not null", self.id] )
    self.total_tasks = Task.count( :conditions => ["milestone_id = ?", self.id] )
    self.save

  end

  def to_s
    name
  end

  def get_project_currency(project_id)
    project = Project.find project_id
    project.currency_iso_code
  end

  private
  def validate_dates
     errors.add(:init_date, "Must be before due date ") if self.due_at < self.init_date
  end
end



# == Schema Information
#
# Table name: milestones
#
#  id              :integer(4)      not null, primary key
#  company_id      :integer(4)
#  project_id      :integer(4)
#  user_id         :integer(4)
#  name            :string(255)
#  description     :text
#  due_at          :datetime
#  position        :integer(4)
#  completed_at    :datetime
#  total_tasks     :integer(4)      default(0)
#  completed_tasks :integer(4)      default(0)
#  scheduled_at    :datetime
#  scheduled       :boolean(1)      default(FALSE)
#
# Indexes
#
#  milestones_company_id_index       (company_id)
#  milestones_project_id_index       (project_id)
#  milestones_company_project_index  (company_id,project_id)
#  fk_milestones_user_id             (user_id)
#

