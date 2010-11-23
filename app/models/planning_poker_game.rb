class PlanningPokerGame < ActiveRecord::Base

  has_many :planning_poker_vote, :dependent => :destroy

  belongs_to :task

end
