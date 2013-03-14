class Reports::FloatController < ApplicationController
	before_filter :authenticate_user!	
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
				
				facts = current_user.entity.network_facts.between(fact_time: start_date..end_date) #.where(:report_entity => current_user.entity) #, :location_network => default_network)				
				print facts.to_json
#		    	response = {:grid => facts, :location_networks => location_network_list}
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

#				visible_networks = current_user.entity.production_networks
#		    	fill_network_list = JqxConverter.jqxDropDownList(visible_networks)
		    	
#				if params['fill_network_id'].nil?
#					default_network = visible_networks[0]
#				else
#					default_network = Network.find(params['fill_network_id'])					
#				end
				facts = current_user.entity.network_facts.between(fact_time: start_date..end_date).where(:location_network_type => 1).gt(life_cycle_completed_cycles: 0)
#				facts = AssetFillToFillCycleFactByFillNetwork.between(fact_time: start_date..end_date).where(:report_entity => current_user.entity) #, :fill_network => default_network)				
		    	response = {:grid => facts}
		    	# response = {:grid => facts, :fill_networks => fill_network_list}
		    	 
		    	render json: response		
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

#				visible_networks = current_user.entity.distribution_networks
#		    	delivery_network_list = JqxConverter.jqxDropDownList(visible_networks)
		    	
#				if params['fill_network_id'].nil?
#					default_network = visible_networks[0]
#					print params['delivery_network_id'].class.to_s + "<---"
#				else
#					default_network = Network.find(params['delivery_network_id'])					
#				end
				
				facts = current_user.entity.network_facts.between(fact_time: start_date..end_date).gt(life_cycle_completed_cycles: 0).or({location_network_type: 2}, {location_network_type: 3})
				
#				facts = NetworkFact.between(fact_time: start_date..end_date).where(:report_entity => current_user.entity) #), :delivery_network => default_network)
		    	
		    	response = {:grid => facts}
		    	#response = {:grid => facts, :delivery_networks => delivery_network_list}
		    	 
		    	render json: response		
		    }
		end			
	end	
end
