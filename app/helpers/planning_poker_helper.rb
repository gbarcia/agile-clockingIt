module PlanningPokerHelper

  def vote_for_user_in_game (game)
    vote_info = game.planning_poker_votes.find(:first, :conditions => ['user_id = ?', current_user.id])
    if vote_info.vote.nil?
      return 'No realizado'
    else
      return vote_info.vote.to_s
    end
  end

  def players_numbers_for_game (game)
    result = game.planning_poker_votes.count(:conditions => ['planning_poker_game_id = ? and status = ?',game.id, 1])
    total_players = game.planning_poker_votes.count(:conditions => ['planning_poker_game_id = ?',game.id])
    return result.to_s + '/' + total_players.to_s
  end

  def user_is_leader_from_this_game?(game)
    game.task.project.leader_id == current_user.id
  end
end
