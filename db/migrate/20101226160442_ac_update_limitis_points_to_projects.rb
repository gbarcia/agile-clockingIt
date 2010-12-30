class AcUpdateLimitisPointsToProjects < ActiveRecord::Migration
  def self.up
    change_column 'projects','limit_points_per_user_stories', :integer,:default => 300
    change_column 'projects','limit_points_per_business_value_stories', :integer,:default => 300
    change_column 'estimation_settings','points_per_hour', :float,:default => 3.0
  end

  def self.down
    change_column 'projects', 'limit_points_per_user_stories', :integer, :default => 100
    change_column 'projects', 'limit_points_per_business_value_stories', :integer, :default => 100
    change_column 'estimation_settings','points_per_hour', :float,:default => 0.6
  end
end
