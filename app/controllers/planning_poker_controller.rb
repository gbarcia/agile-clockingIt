require 'juggernaut'
class PlanningPokerController < ApplicationController
  
  def config
    game = PlanningPokerGame.new
    game.task_id = params[:us_id]
    if !game_exist?(params[:us_id])
      game.save!
    else
      game = PlanningPokerGame.find_by_task_id params[:us_id]
    end
    @game_config = game
    @game_config.due_at = tz.utc_to_local(@game_config.due_at) unless @game_config.due_at.nil?
    actual_votes = game.planning_poker_votes
    actual_users = users_for_game(actual_votes)
    @actual_users = actual_users
    project_global_users = game.task.project.users
    @project_users = project_global_users - actual_users
    @user_story = game.task
  end

  def update_config
    planning_poker_game_id = params[:planning_poker_id]
    id_users_to_play = Array.new
    if !params[:id_users_to_play].nil?
      params[:id_users_to_play].each do |id_user|
        id_users_to_play << id_user.to_i
      end
    end
    game = PlanningPokerGame.find planning_poker_game_id
    actual_users_id = users_ids_for_game(game.planning_poker_votes)
    user_id_list = actual_users_id - id_users_to_play
    remove_users_to_game(user_id_list)
    update_users_to_game(id_users_to_play, game.id)
    ppoker_game = PlanningPokerGame.find planning_poker_game_id
    ppoker_game.due_at = tz.local_to_utc Time.parse params[:due_at] if params[:due_at]
    ppoker_game.save!
    send_invitations_mail(id_users_to_play, game)
  end

  def table
  end

  def historial
  end

  def send_message
    Juggernaut.publish(params[:channel], current_user.name + ": " + params[:message])
  end

  private

  def send_invitations_mail (id_users_to_play, game)
    task = Task.find game.task_id
    id_users_to_play.each do |id_user|
      user = User.find id_user
      Notifications::deliver_planning_poker_invitation(game, task, user)
    end
  end

  def remove_users_to_game (user_ids_list)
    PlanningPokerVote.destroy_all(['user_id in(?)', user_ids_list.join(',')])
  end

  def update_users_to_game (users_ids_list, game_id)
    users_ids_list.each do |user_id|
      ppvote = PlanningPokerVote.new
      ppvote.user_id = user_id
      ppvote.planning_poker_game_id = game_id
      if !user_exist_for_game(game_id, user_id)
        ppvote.save!
      end
    end
  end
  
  def game_exist?(task_id)
    game = PlanningPokerGame.find_by_task_id task_id
    return !game.nil?
  end

  def user_exist_for_game(id_game, id_user)
    user = PlanningPokerVote.find(:all, :conditions => ['user_id = ? and planning_poker_game_id = ?',id_user, id_game])
    return !user.empty?
  end

  def users_for_game(actual_votes)
    actual_users = Array.new
    actual_votes.each do |vote|
      user = User.find vote.user_id
      actual_users <<  user
    end
    return actual_users
  end

  def users_ids_for_game(actual_votes)
    actual_users = Array.new
    actual_votes.each do |vote|
      actual_users <<  vote.user_id
    end
    return actual_users
  end

  def users_for_game_query (actual_users)
    result = ""
    count = 1
    actual_users.each do |user|
      result += user.id.to_s
      if count < actual_users.length
        result += ','
      end
      count = count + 1
    end
    return result
  end

end
