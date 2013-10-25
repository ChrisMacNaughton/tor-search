# encoding: utf-8
# advertisers can apply coupon codes to their account
class Coupon < ActiveRecord::Base
  attr_accessible :code, :value
end
