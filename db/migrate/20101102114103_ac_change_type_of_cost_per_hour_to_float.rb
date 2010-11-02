class AcChangeTypeOfCostPerHourToFloat < ActiveRecord::Migration
  def self.up
    change_column 'projects', 'cost_per_hour', :float
  end

  def self.down
    change_column 'projects', 'cost_per_hour', :decimal
  end
end
