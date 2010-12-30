class CreateEstimationSettings < ActiveRecord::Migration
  def self.up
    create_table :estimation_settings do |t|
      t.float   :velocity, :default => 30.0
      t.float   :expert_judgment, :default => 20.0
      t.float   :planning_poker, :default => 50.0
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :estimation_settings
  end
end
