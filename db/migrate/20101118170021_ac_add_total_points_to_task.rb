class AcAddTotalPointsToTask < ActiveRecord::Migration
  def self.up
    add_column "tasks","total_points",:integer, :default => 0
  end

  def self.down
    remove_column "tasks", "total_points"
  end
end
