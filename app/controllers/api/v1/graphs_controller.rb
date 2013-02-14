=begin
class Api::V1::GraphsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_filter :authenticate_user!

	def filters
		filters = []
		print params.to_s		
		if !params['filters']['asset_types'].nil?
			filters.push( { :label => 'Asset Types', :id => :asset_types_filter, :options => get_asset_types.map {|asset_type| [asset_type.description, asset_type.id]} } )					
		end
		if !params['filters']['locations'].nil?
			filters.push( { :label => 'Locations', :id => :locations_filter, :options => get_locations.map {|location| [location.description, location.id]} } )					
		end
		if !params['filters']['products'].nil?
			filters.push( { :label => 'Products', :id => :products_filter, :options => get_products.map {|product| [product.description, product.id]} } )					
		end
		if !params['filters']['handle_codes'].nil?
			filters.push( { :label => 'Actions', :id => :handle_codes_filter, :options => get_handle_codes.map {|handle_code| [handle_code.description, handle_code.id]} } )					
		end
		if !params['filters']['users'].nil?
			filters.push( { :label => 'Users', :id => :users_filter, :options => get_users.map {|user| [user.email, user.id]} } )					
		end	
		respond_to do |format|
      		format.json { render json: filters }
	    end	

	end	


	def asset_daily_facts_line_chart_with_view_finder
		products = get_products
		asset_types = get_asset_types		

		data_set_array = []
		print params['filter']
		get_date_dimension.each do |date_dimension|			
			products.each do |product|
				asset_types.each do |asset_type|
					asset_daily_facts = AssetDailyFact.where(:asset_type => asset_type, :product => product)
	
					if asset_daily_facts.count > 0
						key = product.description + " " + asset_type.description
						values = []

						x = date_dimension.created_at.to_i * 1000 # "#{date_dimension.month_of_year.to_s}-#{date_dimension.day_of_month}-#{date_dimension.year}"
						y = asset_daily_facts.count
						values.push( [x, y] )
						data_set_array.push( {:key => key, :values => values } )			
					end					
				end
			end
		end		
		respond_to do |format|
      		format.json { render json: data_set_array }
	    end	
	end
	
	def asset_type_by_product_group_stacked_bar_chart
		products = get_products
		asset_types = get_asset_types
		
		data_set_array = []				
		products.each do |product|
			if Asset.where(:product => product).count > 0
				key = product.description
				values = []
				asset_types.each do |asset_type|
					x = asset_type.description
					y = Asset.where(:product => product, :asset_type => asset_type).count
					values.push({:x => x, :y => y})			
				end	
				values.push( {:x => 'Unknown', :y => current_user.entity.assets.where(:product => product, :asset_type => nil).count } )
				data_set_array.push( {:key => key, :values => values } )							
			end
		end				
		respond_to do |format|
      		format.json { render json: data_set_array  }
	    end	
	end
end
=end