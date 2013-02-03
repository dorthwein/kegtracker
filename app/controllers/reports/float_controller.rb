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
		    	if !params['date'].nil?
					date = DateTime.parse(params['date'])

		    		options[:start_date] = date
		    		options[:end_date] = date

		    	end

				visible_networks = Network.visible_networks({:entity => current_user.entity})
		    	location_network_list = []		    	
		    	location_network_list = visible_networks.map {|x| 
					{:html => x.description, :value => x._id}		    	
		    	}

				if params['location_network_id'].nil?
					options[:location_network] = visible_networks[0]
				else
					options[:location_network] = Network.find(params['location_network_id'])					
				end

				facts = AssetActivitySummaryFact.grid_facts(options)		    	
		    	response = {:grid => facts, :location_networks => location_network_list}
		    	 
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

	def life_cycle_summary_report
		respond_to do |format|  
			format.html
		    format.json { 
		    	render json: @response 
			}			
		end			
	end	
end
