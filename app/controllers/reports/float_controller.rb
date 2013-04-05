class Reports::FloatController < ApplicationController
	before_filter :authenticate_user!	
	layout "web_app"
	# **********************************
	# Float  Health Reports
	# **********************************
	def activity_summary_report_simple
		respond_to do |format|
			format.html 

		    format.json {
		    	options = {:entity => current_user.entity}
    			if params['date'].nil?
					date = Time.new().in_time_zone("Central Time (US & Canada)")
    			else
					date = DateTime.parse(params['date'])
    			end

    			
    			start_date = date.beginning_of_day
    			end_date = date.end_of_day

#				visible_networks = current_user.entity.visible_networks
#		    	location_network_list = JqxConverter.jqxDropDownList(visible_networks)

#				if params['location_network_id'].nil?
#					default_network = visible_networks[0]
#				else
#					default_network = Network.find(params['location_network_id'])					
#				end
				
				facts = current_user.entity.network_facts.between(fact_time: start_date..end_date).any_of(
					{:fill_quantity.gt => 0},	
					{:delivery_quantity.gt => 0},
					{:pickup_quantity.gt => 0}, 
					{:move_quantity.gt => 0}, 						
				)
		    	response = {:grid => facts}
		    	
		    	render json: response
			}
		end				
	end	
	def activity_summary_report_advanced
		respond_to do |format|
			format.html 
		    format.json { 
			    render json: @response 
			}
		end				
	end	

	def asset_fill_to_fill_cycle_fact_by_fill_network
		respond_to do |format|  
			format.html
		    format.json {
		    	options = {:entity => current_user.entity}
				
				date = DateTime.parse(params['date'])

    			start_date = date.beginning_of_day
    			end_date = date.end_of_day

				records = current_user.entity.network_facts.between(fact_time: start_date..end_date).gt(fill_life_cycle_completed_cycles: 0).map{|x| {
  					a: x.location_network_description,
  					b: x.product_description,
  					c: x.asset_type_description,
  					d: x.product_entity_description,
  					e: x.fill_life_cycle_avg_time,
  					f: x.fill_life_cycle_min_time,
  					g: x.fill_life_cycle_max_time,
  					h: x.fill_life_cycle_completed_cycles,
  					i: x._id,
				}}
		    	render json: records		
		    }
		end
	end	

	def asset_fill_to_fill_cycle_fact_by_delivery_network
		respond_to do |format|  
			format.html
		    format.json {
		    	options = {:entity => current_user.entity}
								 
				date = DateTime.parse(params['date'])

    			start_date = date.beginning_of_day
    			end_date = date.end_of_day
				
				records = current_user.entity.network_facts.between(fact_time: start_date..end_date).gt(delivery_life_cycle_completed_cycles: 0).map{|x| {
					a: x.location_network_description,
					b: x.product_description,
					c: x.asset_type_description,
					d: x.product_entity_description,
					e: x.delivery_life_cycle_avg_time,
					f: x.delivery_life_cycle_min_time,
					g: x.delivery_life_cycle_max_time,
					h: x.delivery_life_cycle_completed_cycles,
					i: x._id,
				}}
		    	response = records
		    	#response = {:grid => facts, :delivery_networks => delivery_network_list}
		    	 
		    	render json: response		
		    }
		end			
	end	
end
