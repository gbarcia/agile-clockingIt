class AcAddCostPerHourToProjects < ActiveRecord::Migration
  def self.up
    add_column "projects", "cost_per_hour", :decimal, :presition => 8, :default => 0.0
  end

  def self.down
    remove_column "projects", "cost_per_hour"
  end
end
