# encoding: utf-8
TorSearch::Application.routes.draw do

  devise_for :admin

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  get 'a/r' => 'search#ad_redirect', as: :ad_redirect

  get 'errors/error_404'
  get 'errors/error_500'

  get 'graphs' => 'graphs#index', as: :graphs
  get 'graphs/daily' => 'graphs#daily', as: :daily
  get 'graphs/unique' => 'graphs#unique', as: :unique

  get 'r' => 'search#redirect', as: :redirect
  get 'flag' => 'domain#flag_page', as: :content_flag
  post 'flag' => 'domain#create_flag', as: :flags
  scope '(:locale)', locale: /en/ do
    devise_for :advertisers
    get 'add-domain' => 'domain#new', as: :add_link
    post 'add-domain' => 'domain#submit', as: :post_new_link

    get 'instant' => 'instant#new', as: :instant

    get 'advertising' => 'ads#advertising', as: :contact
    post '/advertising' => 'contact#new_message'

    get 'contact' => 'contact#contact', as: :contact
    post '/contact' => 'contact#new_message', as: :messages
    get 'policies' => 'static#policies', as: :policies
    get '/humans.txt' => 'static#humans'
    get '/keyword_tool' => 'keyword_tool#index'
  end

  #
  scope 'ads' do
    # resources :ads do
    #   member do
    #     get 'toggle' => 'ads#toggle', as: :toggle
    #     put 'toggle' => 'ads#toggle', as: :toggle
    #     put 'request_beta' => 'ads#request_beta', as: :request_beta
    #     get 'request_beta' => 'ads#request_beta', as: :request_beta
    #   end
    # end
    #resources :ad_groups
    #get '/ad_campaigns/ad_groups/(:id)' => 'ad_campaigns#ad_groups', as: :ad_campaigns_ad_groups
    resources :ad_campaigns do
      resources :ad_groups
      resources :ads
    end
    resources :ad_groups do
      resources :ads
    end
    resources :ads

  end
  get '/ads' => 'ad_campaigns#index'
  # namespace 'api' do
  #   get 'advertiser_balance' => 'ad#advertiser_balance'
  #   resources :bitcoin_address
  #   resources :payment
  #   resources :ad do
  #     resources :keyword
  #   end
  #   resources :keyword
  # end
  # resources :keywords
  # get '/ads/bitcoin-addresses' => 'ads#payment_addresses', as: :btc_address
  # post '/ads/bitcoin-addresses' => 'ads#get_payment_address', as: :new_address


  resources :payments

  post 'coupons' => 'coupon#create', as: :credit_coupon

  # get 'partials/ads/:partial' => 'ads#partials'
  # get 'partials/keywords/:partial' => 'keywords#partials'
  # get 'partials/payments/:partial' => 'payments#partials'
  root to: 'search#index'

  match '/:locale' => 'search#index', constraints: {locale: /en/}

  match '*not_found', to: 'errors#error_404', as: 'not_found' \
    unless Rails.application.config.consider_all_requests_local
end
