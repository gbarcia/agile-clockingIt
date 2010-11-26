class PlanningPokerGame < ActiveRecord::Base

  has_many :planning_poker_votes, :dependent => :destroy

  belongs_to :task

end
