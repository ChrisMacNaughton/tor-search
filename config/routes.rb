TorSearch::Application.routes.draw do

  devise_for :admin

  root to: 'search#index', as: :search

  get 'r' => 'search#redirect', as: :redirect
  get 'add-domain' => 'domain#new', as: :add_link
  post 'add-domain' => 'domain#submit', as: :post_new_link

  get 'instant' => 'instant#new', as: :instant

  get 'advertising' => 'advertising#advertising', as: :contact
  post '/advertising' => 'contact#new_message'

  get 'contact' => 'contact#contact', as: :contact
  post '/contact' => 'contact#new_message'
  get 'policies' => 'static#policies', as: :policies
  # Admin routes
  get 'admin' => 'admin#index'
  get 'admin/status' => 'admin#status'

  namespace :admin do
    get 'searches' => 'search#index', as: :admin_searches
    get 'searches/:id' => 'search#show', as: :admin_search
  end
  get 'admin/searches/:id/clicks' => 'admin#clicks', as: :admin_clicks
  get 'admin/pages' => 'admin#pages', as: :admin_pages
  get 'admin/page' => 'admin#page', as: :admin_page

end
