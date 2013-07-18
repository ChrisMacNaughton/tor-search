class ContentFlag < ActiveRecord::Base
  belongs_to :content, polymorphic: true
  belongs_to :flag_reason

  attr_accessible :content_id, :content_type, :reason, :content,
    :flag_reason_id, :flag_reason

  def message
    if flag_reason_id.nil?
      reason
    else
      flag_reason.description
    end
  end
end
