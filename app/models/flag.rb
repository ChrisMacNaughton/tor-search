class Flag < ActiveRecord::Base
  belongs_to :query
  belongs_to :flag_reason
  attr_accessible :path, :title, :query_id, :flag_reason_id
end
