class AcAddProjectIdToRoadmapMilestone < ActiveRecord::Migration
  def self.up
    add_column 'roadmap_milestones', 'project_id', :integer
  end

  def self.down
    remove_column 'roadmap_milestones', 'project_id'
  end
end
