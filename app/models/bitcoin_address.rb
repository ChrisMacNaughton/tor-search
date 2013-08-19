class BitcoinAddress < ActiveRecord::Base
  belongs_to :advertiser
  attr_accessible :address
end
