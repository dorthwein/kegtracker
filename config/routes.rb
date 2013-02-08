Cobalt::Application.routes.draw do 	
  	match 'access_denied' => 'access_denied#index', :via => [:get, :post]  	

	namespace :maintenance do 
		
		match 'network_memberships/new_distributor_partnership' => 'network_memberships#new_distributor_partnership', :via => [:get, :post]	
		

		resources :rfid_antennas
		resources :rfid_readers	  
		match 'rfid_readers/reader_save' => 'rfid_readers#reader_save', :via => [:get, :post]
		match 'rfid_readers/reader_delete' => 'rfid_readers#reader_delete', :via => [:get, :post]
		match 'rfid_readers/reader_new' => 'rfid_readers#reader_new', :via => [:get, :post]
		match 'rfid_readers/reader_select' => 'rfid_readers#reader_select', :via => [:get, :post]
	

		match 'rfid_readers/antennas' => 'rfid_readers#antennas', :via => [:get, :post]
	  	match 'rfid_readers/antenna_select' => 'rfid_readers#antenna_select', :via => [:get, :post]
		match 'rfid_readers/antenna_save' => 'rfid_readers#antenna_save', :via => [:get, :post]
		match 'rfid_readers/antenna_new' => 'rfid_readers#antenna_new', :via => [:get, :post]
		match 'rfid_readers/antenna_delete' => 'rfid_readers#antenna_delete', :via => [:get, :post]

	  	resources :locations 
#		devise_for :users	  	
	  	resources :users 
	    resources :networks	  			  	

	  	resources :network_memberships
	  	
	  	resources :distribution_partnerships
	  	resources :production_partnerships
	  	resources :leasing_partnerships

	  	resources :products  	
	  	resources :barcodes
	  	resources :production 
	    resources :barcode_makers  	
		
	    match 'barcode_maker/download' => 'barcode_makers#download', :via => [:get, :post]	
	end  
  
#	match 'current_inventory_by_network' => 'home#current_inventory_by_network', :via => [:get, :post]
  	
  	namespace :dashboard do 
		match 'viewer' => 'viewer#index', :via => [:get, :post]  	
  	end

	namespace :reports do 
#		match 'viewer' => 'viewer#index', :via => [:get, :post]  	
		
		# Asset
		match 'asset/sku_summary_report_advanced' => 'asset#sku_summary_report_advanced', :via => [:get, :post]
		match 'asset/sku_summary_report_simple' => 'asset#sku_summary_report_simple', :via => [:get, :post]		
		
		match 'asset/browse' => 'asset#browse', :via => [:get, :post]		
		match "asset/browse/row_select" => 'asset#browse_row_select', :via => [:get, :post]
		match "asset/browse/life_cycle_select" => 'asset#browse_life_cycle_select', :via => [:get, :post]

		# Location
		match 'location/browse' => 'location#browse', :via => [:get, :post]		
		match "location/browse/row_select" => 'location#browse_row_select', :via => [:get, :post]		
		match "location/browse/asset_select" => 'location#browse_asset_select', :via => [:get, :post]				

		# Network
		match 'network/in_out_asset_report_advanced' => 'network#in_out_asset_report_advanced', :via => [:get, :post]
		match 'network/in_out_asset_report_simple' => 'network#in_out_asset_report_simple', :via => [:get, :post]		

		match 'network/performance_scorecard_report' => 'network#performance_scorecard_report', :via => [:get, :post]
		
		# Float
		match 'float/life_cycle_summary_report' => 'float#life_cycle_summary_report', :via => [:get, :post]	
		match 'float/activity_summary_report_simple' => 'float#activity_summary_report_simple', :via => [:get, :post]
		match 'float/activity_summary_report_advanced' => 'float#activity_summary_report_advanced', :via => [:get, :post]
	end
	
	namespace :system do
		resources :product_types
	  	resources :entity_types
		resources :entities    	
	  	resources :handle_codes
		resources :asset_types  
		resources :asset_states
		resources :measurement_units

		match 'rfid_reads' => 'rfid_reads#read', :via => [:get, :post] 						
	end

	namespace :scanners do 
#		resources :rfid_readers	
		match "rfid_readers" => 'rfid_readers#index', :via => [:get, :post]
		match "rfid_readers/row_select" => 'rfid_readers#browse_row_select', :via => [:get, :post]
		match "rfid_readers/antenna_select" => 'rfid_readers#antenna_select', :via => [:get, :post]
		match "rfid_readers/antenna_update" => 'rfid_readers#antenna_update', :via => [:get, :post]

		match 'barcode' => 'barcode#index', :via => [:get, :post]
		
		match 'barcode/scanTable' => 'barcode#scanTable', :via => [:get, :post]	  
		match 'barcode/scan' => 'barcode#scan', :via => [:get, :post]  
		
	end

	namespace :api do 		
		# Widgets
		match 'filter_tree_widget' => 'widgets#filter_tree_widget', :via => [:get, :post]
		
		# Charts
		match 'assets_by_network' => 'charts#assets_by_network', :via => [:get, :post]		
		match 'sku_by_network' => 'charts#sku_by_network', :via => [:get, :post]		
		match 'current_sku_quantities' => 'charts#current_sku_quantities', :via => [:get, :post]		


		namespace :v1 do
		  match 'check_connection' => 'check_connection#index', :via => [:get, :post]
		  match 'scan' => 'scans#scan', :via => [:get, :post]		
		  match 'locations' => 'locations#index', :via => [:get, :post]
		  match 'products' => 'products#index', :via => [:get, :post]
		  match 'asset_types' => 'asset_types#index', :via => [:get, :post] 
		end	
	end

#  resources :reports

# resources :authorizations
# resources :products
# resources :entities

	devise_for :users
	resources :users 

  	namespace :public do 
		match 'home' => 'home#index', :via => [:get, :post]
		match 'contact' => 'contact#index', :via => [:get, :post]		
		match 'join' => 'join#index', :via => [:get, :post]		
		match 'order' => 'order#index', :via => [:get, :post]				
		match 'members' => 'members#index', :via => [:get, :post]						
		match 'about' => 'about#index', :via => [:get, :post]								
		match 'pricing' => 'pricing#index', :via => [:get, :post]								
	end
  	root :to => 'home#index'
#  resources :locations

  #devise_for :users, :controllers => {:sessions => 'api/v1/sessions'}, :skip => [:sessions] do
 #   match 'api/v1/login' => 'api/v1/sessions#create', :via => [:get, :post]
#    get 'api/logout' => 'api/v1/sessions#destroy', :as => :destroy_user_session
  #end
	

  
  # The priority is based upon order of creation:
  # first created -> highest priority.c

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
   

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

end
