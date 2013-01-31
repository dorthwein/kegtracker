class PropagateDescriptionJob
	def initialize
	end	
	
# LOCATIONS
	def location location_id
		# Find effected assets & save
		Asset.where(:location_id => location_id).each do |target|
			target.save
		end
	end
	handle_asynchronously :location

# PRODUCTS
	def product product_id
		# Find effected assets & save
		Asset.where(:product_id => product_id).each do |target|
			target.save
		end
	end	
	handle_asynchronously :product

# Entity
	def entity entity_id
		Asset.where(:entity_id => entity_id).each do |target|
			target.save
		end
		Location.where(	:entity_id => entity_id).each do |target|		
			target.save
		end
	end
	handle_asynchronously :entity

# Networks	
	def network network_id
		# Find effected assets & save
		Asset.any_of( 	{ :fill_network_id => network_id }, 
						{ :network_id => network_id } ).each do |target|		
			target.save
		end
		
		Location.where(	:network_id => network_id).each do |target|				
			target.save
		end		
	end	
	handle_asynchronously :network	

# Asset Type	
	def asset_type asset_type_id
		# Find effected assets & save
		Asset.where(	:asset_type_id => asset_type_id).each do |target|
			target.save
		end
	end	
	handle_asynchronously :asset_type
	
# Asset State	
	def asset_state asset_state_id
		# Find effected assets & save
		Asset.where(	:asset_state_id => asset_state_id).each do |target|		
			target.save
		end
	end	
	handle_asynchronously :asset_state	

# User Email	
	def user user_id
		# Find effected assets & save
			Asset.where(	:user_id => user_id).each do |target|
				target.save
		end
	end	
	handle_asynchronously :user	
	
# Handle Code	
	def handle_code handle_code_id
		# Find effected assets & save
		Asset.where(	:handle_code_id => handle_code_id).each do |target|		
			target.save
		end
	end		
	handle_asynchronously :handle_code
end