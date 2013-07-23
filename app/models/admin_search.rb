class AdminSearch < ActiveRecord::Base
  belongs_to :admin

  store :sort_params
  store :search_params

  validates :controller_class, :search_params, presence: true

  scope :for_class, lambda { |c| where(controller_class: c.to_s).limit(1) }
end

# == Schema Information
# Schema version: 20121015175445
#
# Table name: user_searches
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  controller_class :string(255)
#  search_params    :text
#  sort_params      :text
#

