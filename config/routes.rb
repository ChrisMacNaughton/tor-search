TorSearch::Application.routes.draw do

  devise_for :admin

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :advertisers

  root to: 'search#index', as: :search
  post 'payments' => 'payments#index'
  get 'graphs' => 'graphs#index', as: :graphs
  get 'graphs/daily' => 'graphs#daily', as: :daily
  get 'graphs/unique' => 'graphs#unique', as: :unique

  get 'r' => 'search#redirect', as: :redirect
  get 'add-domain' => 'domain#new', as: :add_link
  post 'add-domain' => 'domain#submit', as: :post_new_link

  get 'instant' => 'instant#new', as: :instant

  get 'advertising' => 'ads#advertising', as: :contact
  post '/advertising' => 'contact#new_message'

  get 'contact' => 'contact#contact', as: :contact
  post '/contact' => 'contact#new_message', as: :messages
  get 'policies' => 'static#policies', as: :policies

  get '/keyword_tool' => 'keyword_tool#index'
  get '/ads/new-address' => 'ads#get_payment_address', as: :new_btc_address

  resources :ads do
    resources :keywords
    member do
      put "toggle" => 'ads#toggle', as: :toggle
      put "request_beta" => 'ads#request_beta', as: :request_beta
    end
  end
  post 'coupons' => 'coupon#create', as: :credit_coupon
  get 'a/r' => 'search#ad_redirect', as: :ad_redirect

  post '/payment' => 'payment#index'

  get "errors/error_404"
  get "errors/error_500"

  # See http://ramblinglabs.com/blog/2012/01/rails-3-1-adding-custom-404-and-500-error-pages for more info
  match '*not_found', to: 'errors#error_404', as: 'not_found' unless Rails.application.config.consider_all_requests_local

end
