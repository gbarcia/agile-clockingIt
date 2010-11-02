class AcAddPointsToTask < ActiveRecord::Migration
  def self.up
    add_column "tasks", "points_expert_judgment", :integer, :default => 0
    add_column "tasks", "points_team_velocity", :integer,  :default => 0
    add_column "tasks", "points_planning_poker", :integer, :default => 0
  end

  def self.down
    remove_column "tasks", "points_expert_judgment"
    remove_column "tasks", "points_team_velocity"
    remove_column "tasks", "points_planning_poker"
  end
end
