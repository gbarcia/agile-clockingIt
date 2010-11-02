class AcAddTaskBusinessValue < ActiveRecord::Migration
  def self.up
    add_column "tasks", "business_value", :integer
  end

  def self.down
    remove_column "tasks", "business_value"
  end
end
