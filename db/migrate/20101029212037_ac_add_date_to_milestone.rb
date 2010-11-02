class AcAddDateToMilestone < ActiveRecord::Migration
  def self.up
    add_column "milestones", "init_date", :datetime
  end

  def self.down
    remove_column "milestones", "init_date"
  end
end
