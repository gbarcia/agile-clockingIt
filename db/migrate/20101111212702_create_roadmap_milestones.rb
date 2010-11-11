class CreateRoadmapMilestones < ActiveRecord::Migration
  def self.up
    create_table :roadmap_milestones do |t|
      t.column "title", :string
      t.column "description", :string
      t.column "color_code", :string
      t.column "date", :timestamp
      t.timestamps
    end
  end

  def self.down
    drop_table :roadmap_milestones
  end
end
