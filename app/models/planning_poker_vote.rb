class PlanningPokerVote < ActiveRecord::Base

  belongs_to :planning_poker_game

  belongs_to :user

end
