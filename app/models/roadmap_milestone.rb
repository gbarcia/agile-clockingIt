require 'simile_timeline'

class RoadmapMilestone < ActiveRecord::Base

  belongs_to :project

  acts_as_simile_timeline_event(
    :fields => {
      :start        => :date,
      :title        => :title,
      :description  => :description
    }
  )

end
