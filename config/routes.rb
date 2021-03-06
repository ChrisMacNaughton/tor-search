# encoding: utf-8
TorSearch::Application.routes.draw do

  get "trending/index"

  get "trending/search"

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
    get '/search' => 'search#search', as: :search
    get 'add-domain' => 'domain#new', as: :add_link
    post 'add-domain' => 'domain#submit', as: :post_new_link

    get 'instant' => 'instant#new', as: :instant

    get 'advertising' => 'ads#advertising'
    post '/advertising' => 'contact#new_message'

    get '/contact' => 'contact#contact', as: :contact
    post '/contact' => 'contact#new_message', as: :messages
    get 'policies' => 'static#policies', as: :policies
    get '/humans.txt' => 'static#humans'
    get '/keyword_tool' => 'keyword_tool#index'

    get '/trending' => 'trending#index'
    get '/trending/explore' => 'trending#search'
  end
  get '/trending/graph' => 'trending#search_graph', as: :search_graph
  scope 'ads' do
    resources :campaigns, controller: :ad_campaigns do
      resources :ad_groups
      resources :ads
      resources :keywords, controller: :ad_group_keywords
    end
    resources :ad_groups do
      resources :ads
      resources :keywords, controller: :ad_group_keywords
    end
    resources :ads do
      get 'delete' => 'ads#delete', as: :delete
      get 'restore' => 'ads#restore', as: :restore
      get 'toggle' => 'ads#toggle', as: :toggle
      # put 'toggle' => 'ads#toggle', as: :toggle
    end
    resources :keywords, controller: :ad_group_keywords do
      post 'delete' => 'ad_group_keywords#delete', as: :delete
      get 'toggle' => 'ad_group_keywords#toggle', as: :toggle
      # put 'toggle' => 'ad_group_keywords#toggle', as: :toggle
    end
    resources :campaigns do
      get 'toggle' => 'ad_campaigns#toggle', as: :toggle
      # put 'toggle' => 'ad_campaigns#toggle', as: :toggle
    end
    resources :ad_groups do
      get 'toggle' => 'ad_groups#toggle', as: :toggle
      # put 'toggle' => 'ad_groups#toggle', as: :toggle
    end
    get 'billing' => 'billing#index', as: :billing
  end
  get '/ads' => 'ad_campaigns#index'

  post '/ads/bitcoin-address' => 'ads#get_payment_address', as: :new_address


  post 'payments' => 'payments#new_bitcoin_payment'

  post 'coupons' => 'coupon#create', as: :credit_coupon
  get '/ads/campaigns' => 'ad_campaigns#index', as: 'advertiser_root'
  root to: 'search#index'

  get '/:locale' => 'search#index', constraints: {locale: /en/}

  match '*not_found', to: 'errors#error_404', as: 'not_found', via: [:get, :post, :put] \
    unless Rails.application.config.consider_all_requests_local
end
