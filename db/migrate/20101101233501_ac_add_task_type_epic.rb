class AcAddTaskTypeEpic < ActiveRecord::Migration
  def self.up
    PropertyValue.create :property_id => 1, :value => 'Epic', :color => '',
      :default => 0, :position => 4, :icon_url => '/images/task_icons/epic.png'
  end

  def self.down
    PropertyValue.destroy_all :value => 'Epic'
  end
end
