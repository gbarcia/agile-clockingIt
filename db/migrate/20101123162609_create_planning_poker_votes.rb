class CreatePlanningPokerVotes < ActiveRecord::Migration
  def self.up
    create_table :planning_poker_votes do |t|

      t.timestamps
      t.float :vote
      t.datetime :vote_date
      t.integer :user_id
      t.integer :planning_poker_game_id
    end
  end

  def self.down
    drop_table :planning_poker_votes
  end
end
