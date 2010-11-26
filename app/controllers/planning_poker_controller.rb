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
    @project_users = game.task.project.users
  end

  def table
  end

  def historial
  end

  private
  def game_exist?(task_id)
    game = PlanningPokerGame.find_by_task_id task_id
    return !game.nil?
  end

end
