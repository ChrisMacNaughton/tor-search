TorSearch::Application.routes.draw do

  devise_for :admin

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :advertisers

  root to: 'search#index', as: :search
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
  post '/contact' => 'contact#new_message'
  get 'policies' => 'static#policies', as: :policies
  # Admin routes

  #get 'admin' => 'admin#index'
  get '/ads/new-address' => 'ads#get_payment_address', as: :new_btc_address

  resources :ads do
    member do
      put "toggle" => 'ads#toggle', as: :toggle
      put "request_beta" => 'ads#request_beta', as: :request_beta
    end
  end

  get 'a/r' => 'search#ad_redirect', as: :ad_redirect

  #namespace :admin do
  #  resources :ads, controller: 'ad'
  #  get 'searches' => 'search#index', as: :admin_searches
  #  get 'searches/:id' => 'search#show', as: :admin_search
  #
  #  resources :messages
  #end
  #get 'admin/searches/:id/clicks' => 'admin#clicks', as: :admin_clicks
  #get 'admin/pages' => 'admin#pages', as: :admin_pages
  #get 'admin/page' => 'admin#page', as: :admin_page

  post '/payment' => 'payment#index'
end
