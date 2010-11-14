class AcAddColorToMilestoneIteration < ActiveRecord::Migration
  def self.up
    add_column "milestones", "color", :string, :default => "blue"
  end

  def self.down
    remove_column "milestones", "color"
  end
end
