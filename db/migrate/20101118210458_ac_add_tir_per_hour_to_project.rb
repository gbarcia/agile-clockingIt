class AcAddTirPerHourToProject < ActiveRecord::Migration
  def self.up
    add_column "projects","tir_per_hour",:float, :default => 0.0
  end

  def self.down
    remove_column "projects", "tir_per_hour"
  end
end
