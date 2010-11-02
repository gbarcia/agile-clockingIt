class AcAddBudgetToIteration < ActiveRecord::Migration
  def self.up
    add_column "milestones", "budget", :float, :default => 0.0
  end

  def self.down
    remove_column "milestones", "budget"
  end
end
