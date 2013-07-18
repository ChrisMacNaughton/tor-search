class CrawlerLogEntry < ActiveRecord::Base
  belongs_to :page
  attr_accessible :action, :reason, :type_str, :page
end
