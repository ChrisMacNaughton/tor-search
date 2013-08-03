class Link < ActiveRecord::Base
  belongs_to :from_target, polymorphic: true
  belongs_to :to_target, polymorphic: true

  attr_accessible :from_target, :from_target_id, :to_target, :to_target_id,
    :anchor_text

  validates :to_target_id, uniqueness: {scope: :from_target_id}

end
