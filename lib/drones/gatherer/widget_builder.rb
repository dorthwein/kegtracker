=begin
class WidgetBuilder < ApplicationController
	def initialize user, fact_time_start = Time.new.beginning_of_day, fact_time_end = Time.new.end_of_day
		# Gatherer Params
		@fact_time_start = fact_time_start
		@fact_time_end = fact_time_end

		@entity = user.entity
		@user = user
	end

	def filter_tree_widget

		gatherer = Gatherer.new(@entity)
	
		asset_types = gatherer.get_asset_types.map{|asset_type| {:label => asset_type.description, :value => asset_type._id} }
		asset_states = gatherer.get_asset_states.map{|asset_state| {:label => asset_state.description, :value => asset_state._id} }


	
#		asset_summary_facts.group_by{ |asset_summary_fact| asset_summary_fact.product_id }.each do |asset_summary_fact_by_product|


		network, product, asset_entity = gatherer.asset_activity_fact_criteria				
			
		asset_activity_facts = AssetActivityFact.between(fact_time: @fact_time_start..@fact_time_end).any_of(network, product, asset_entity )
		
#		print 'mark'
#		print location_networks.to_json


		products = asset_activity_facts.group_by{| asset_activity_fact_by_product| asset_activity_fact_by_product.product }.map{|product| product[0]}.map{|product| {:label => product.description, :value => product._id } }
		location_networks = asset_activity_facts.group_by{| asset_activity_fact_by_location_network| asset_activity_fact_by_location_network.location_network }.map{|location_network| location_network[0]}.map{|location_network| {:label => location_network.description, :value => location_network._id  } }

		tree = 	[
					{ 							
						:label => 'Location Networks',
						:value => 'location_network_id',
						:expanded => true,
						:checked => true,
						:items => location_networks
					},					
					{ 	
						:label => 'Products', 
						:value => 'product_id',
						:expanded => true,
						:checked => true, 
						:items => products
					},
					{ 	
						:label => 'Asset Types', 
						:value => 'asset_type_id',
						:expanded => true, 
						:checked => true,
						:items => asset_types
					},
					{ 	
						:label => 'Asset States', 
						:value => 'asset_state_id',
						:expanded => true,
						:checked => true, 
						:items => asset_states
					}	
				]
			return tree

		

		# AssetActivityFact.between.(fact_time: @fact_time_start..@fact_time_end).any_of( location_networks, products, entity ).only(:product).only(:product).group_by{| asset_activity_fact_by_product| asset_activity_fact_by_product.product  }


		
	end
end
=end