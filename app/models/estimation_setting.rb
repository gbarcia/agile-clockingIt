class EstimationSetting < ActiveRecord::Base
  belongs_to :project

  validate  :validate_sum
  
  private
  def validate_sum
    errors.add("the sum of three factors must be 100") if (self.expert_judgment + self.planning_poker + self.velocity) != 100.0
  end
end
