TorSearch::Application.routes.draw do

  devise_for :admin

  root to: 'search#index'

  get 'r' => 'search#redirect', as: :redirect
  get 'add-domain' => 'domain#new', as: :add_link
  post 'add-domain' => 'domain#submit', as: :post_new_link

  get 'instant' => 'instant#new', as: :instant

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

  #get '/images' => 'image#index'
  #get '/images/list' => 'image#list'
  #get '/images/flag/:id' => 'image#flag', as: 'image_flag'
  #post '/images/flag' => 'image#complete_flag', as: 'save_flag'
  #get '/images/show/:id(/:style)' => 'image#show'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
