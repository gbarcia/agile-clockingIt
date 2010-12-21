class PlanningPokerGame < ActiveRecord::Base

  has_many :planning_poker_votes, :dependent => :destroy

  belongs_to :task

  def closed?
    return self.closed == true
  end

  def undate?(tz)
    actual_time = Time.now
    if  tz.utc_to_local(self.due_at) > actual_time.strftime("%Y-%m-%d %H:%M:%S").to_time
      return false
    else
      return true
    end
  end

end
