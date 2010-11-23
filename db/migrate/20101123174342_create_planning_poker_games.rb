class CreatePlanningPokerGames < ActiveRecord::Migration
  def self.up
    create_table :planning_poker_games do |t|
      t.datetime :due_at
      t.bool :locked, :default => false
      t.bool :closed, :default => false
      t.integer :task_id
      t.timestamps
    end
  end

  def self.down
    drop_table :planning_poker_games
  end
end
