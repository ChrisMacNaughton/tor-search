class AddLastRobotsToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :robots, :text
    add_column :domains, :last_robots_check, :datetime
  end
end
