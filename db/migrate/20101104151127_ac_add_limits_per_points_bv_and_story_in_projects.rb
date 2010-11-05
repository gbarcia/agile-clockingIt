class AcAddLimitsPerPointsBvAndStoryInProjects < ActiveRecord::Migration
  def self.up
    add_column 'projects', 'limit_points_per_user_stories', :integer, :default => 100
    add_column 'projects', 'limit_points_per_business_value_stories', :integer, :default => 100
  end

  def self.down
    remove_column 'projects', 'limit_points_per_user_stories'
    remove_column 'projects', 'limit_points_per_business_value_stories'
  end
end
