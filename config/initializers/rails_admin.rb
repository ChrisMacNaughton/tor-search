# encoding: utf-8
# RailsAdmin config file. Generated on August 28, 2013 13:06
# See github.com/sferik/rails_admin for more informations
Kaminari.configure do |config|
  config.page_method_name = :per_page_kaminari
end

RailsAdmin.config do |config|  config.main_app_name = ['Tor Search', 'Admin']

  config.current_user_method { current_admin } # auto-generated
  config.audit_with :history, 'Admin'
  config.included_models = %w(
    Ad AdKeyword Admin Advertiser
    BitcoinAddress BannedDomain Coupon Domain InstantResult
    Keyword Message Payment Query Search FlagReason Flag
    )

  config.model 'FlagReason' do
    object_label_method :name
  end

  config.model 'Query' do
    object_label_method :term
  end

  config.model "Keyword" do
    object_label_method :word
  end

  config.model "AdKeyword" do
    object_label_method :word
  end

end
