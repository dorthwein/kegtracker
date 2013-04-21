class Gatherer < ApplicationController
	  	attr_accessor :entity 
	  	attr_accessor :networks

	  	attr_accessor :entity_products
	  	attr_accessor :production_products	  	
	  	attr_accessor :report_products	  	
	  		  	
	  	attr_accessor :locations
	  	attr_accessor :assets	

#		attr_accessor :handle_codes	
	  	attr_accessor :asset_types
	  	attr_accessor :test_data
	
	def initialize entity
		@entity = entity
	end

# *************************
# Products
# *************************	
	def get_production_products
		# Get entities Products
		@production_products = Array.new		
		@production_products = @production_products + @entity.products
		# Get Products this entity has been allowed to produce
		
		@production_products = @production_products.sort_by {|e| e['description'] }		
	end

	def get_entity_products
		# Get entities Products
		@entity_products = Array.new
		@entity_products = @entity_products + @entity.products
	end

	def get_report_products
		# Get entities Products
		get_production_products

		@report_products = Array.new
		@report_products = @report_products + @production_products
	end

# *************************
# Assets
# *************************
	def get_assets
#		@assets = Array.new
		@assets = Asset.any_of( { :location_network.in => get_networks },
										  { :product.in => get_entity_products }, 
										  { :entity => @entity }
							)
		@assets
	end
=begin
	def get_asset_activity_fact
		@asset_activity_facts = AssetActivityFacts.any_of(  
												{ :location_network.in => get_networks },
												{ :product.in => get_entity_products }, 
												{ :entity => @entity }
											)
	end	
=end
	def asset_activity_fact_criteria
			[{ :location_network.in => get_networks },{ :product.in => get_entity_products },{ :entity => @entity }]	
	end
	
	def get_asset_types
		@asset_types = AssetType.all + [nil]
	end

# *************************
# Users
# *************************	
	def get_users
		@users = Array.new
		@users = @users + @entity.users.sort_by {|e| e['email'] }	
	end
# *************************
# Entities
# *************************
	def get_entities
		@entities = Array.new
		@entities = @entities.push(@entity)
	end
# *************************
# Networks
# *************************

	def get_networks
		@networks = Array.new
		@networks = @networks + @entity.networks.sort_by {|e| e['description'] }	
	end


# *************************
# Locations
# *************************
	def get_locations
		locations = Array.new
			
		@entity.networks.each do |network|
			locations = locations + network.locations
		end
		NetworkMembership.where(:entity => @entity, :asset_distribution => true ).each do |distribution_partnership|
			locations = locations + distribution_partnership.network.locations.where(:partner_entity => 1)
		end
		return locations
	end

# *************************
# Reports
# *************************

	def get_asset_activity_summary_facts
		asset_activity_summary_facts = AssetActivitySummaryFact.where(:report_entity => @entity)
		asset_activity_summary_facts		
	end
end







