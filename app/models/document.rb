class Document < ActiveRecord::Base
  belongs_to :domain
  attr_accessible :path, :domain, :domain_id
end
