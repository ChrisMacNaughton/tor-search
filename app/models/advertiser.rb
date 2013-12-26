# encoding: utf-8
# advertisers create ads
class Advertiser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation,
                  :remember_me, :balance, :username, :beta,
                  :beta_requested, :wants_js, :wants_beta, :is_auto_approved
  # attr_accessible :title, :body
  has_many :ads
  has_many :bitcoin_addresses
  has_many :payments
  validates :username,
            uniqueness: {
              case_sensitive: false
            },
            presence: true
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:username)
    if login
      where(conditions) \
        .where(['lower(username) = :value', { value: login.downcase }]) \
        .first
    else
      where(conditions).first
    end
  end

  def to_s
    try(:email) || try(:username)
  end

  def email_required?
    false
  end
end
