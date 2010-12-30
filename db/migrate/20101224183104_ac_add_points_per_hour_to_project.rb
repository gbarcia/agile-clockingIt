class AcAddPointsPerHourToProject < ActiveRecord::Migration
  def self.up
    add_column 'estimation_settings','points_per_hour',:float, :default => 0.5
  end

  def self.down
    remove_column 'estimation_settings','points_per_hour'
  end
end
