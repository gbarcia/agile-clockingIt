class AcAddStatusToPlanningPokerVote < ActiveRecord::Migration
  def self.up
    add_column 'planning_poker_votes', 'status', :boolean, :default => 0
  end

  def self.down
    remove_column 'planning_poker_votes', 'status'
  end
end
