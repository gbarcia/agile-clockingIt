class AcAddClosedAttributeToPlanningPokerGame < ActiveRecord::Migration
  def self.up
    add_column 'planning_poker_games', 'closed', :boolean, :default => 0
  end

  def self.down
    remove_column 'planning_poker_games', 'closed'
  end
end
