require 'simile_timeline'

class RoadmapMilestone < ActiveRecord::Base

  belongs_to :project

  validates_presence_of :title,:date

  def description_presentation
    result = "<p>ROI: "
    result << get_roi.to_s + " %</p><p>"
    result << self.description + "<p>"
  end

  def get_roi
    total_estimate_cost = 0.0
    total_real_cost = 0.0
    iterations = Milestone.find(:all, :conditions => ["project_id = ? and due_at <= ?",self.project_id,self.date])
    iterations.each do |iteration|
      total_estimate_cost += iteration.get_estimate_cost
      total_real_cost += iteration.get_real_cost
    end
    benefist = total_estimate_cost
    roi = ((benefist - total_real_cost)/ total_real_cost) * 100 rescue 0
    if roi.nan? || roi.infinite?
      roi = 0.0
    end
    return (roi * 10**2).round.to_f / 10**2 #round two decimals
  end

end
