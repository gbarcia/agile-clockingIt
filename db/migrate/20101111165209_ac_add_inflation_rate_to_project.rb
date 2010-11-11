class AcAddInflationRateToProject < ActiveRecord::Migration
  def self.up
    add_column 'projects','inflation_rate',:float, :default => 0.0
  end

  def self.down
    remove_column 'projects', 'inflation_rate'
  end
end
