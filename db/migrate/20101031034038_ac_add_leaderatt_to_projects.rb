class AcAddLeaderattToProjects < ActiveRecord::Migration
  def self.up
    add_column "projects", "leader_id", :integer
  end

  def self.down
    remove_column "projects", "leader_id"
  end
end
