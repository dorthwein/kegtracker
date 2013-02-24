class Reports::NetworkController < ApplicationController
	before_filter :authenticate_user!	
# *****************************************
# Network Reports
# *****************************************
	#Incomplete
	def in_out_asset_report_advanced
		respond_to do |format|  
			format.html
		    format.json { 
				gatherer = Gatherer.new current_user.entity

#				build_report = BuildReport.new
#				build_report.asset_location_network_in_out_report

				@response = AssetLocationNetworkInOutSummaryFact.where(:report_entity => current_user.entity).map { |x| {
																						:date => x.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y"),
																						:location_network =>		x.location_network_description,
																						:location_network_asset_type_id => 	x.location_network_asset_type_id,
																						:asset_type => 				x.asset_type_description,
																						:asset_type_id => 				x.asset_type_id,
																						:product => 				x.product_description,
																						:product_entity => 			x.product_entity_description,
																						:sku => 					x.sku_description,
																						:sku_id => 					x.sku_id,
																						:date_id => 				x.fact_time.to_i,
																						:in_total_quantity => 		x.in_total_quantity,
																						:out_total_quantity => 		x.out_total_quantity
					}
				}		
		  	  render json: @response 
			}			
		end			
	end
	def in_out_asset_report_simple
		respond_to do |format|  
			format.html
		    format.json {
		    	options = {:entity => current_user.entity}
				date = DateTime.parse(params['date']) rescue Time.new().in_time_zone("Central Time (US & Canada)")
    			
    			start_date = date.beginning_of_day
    			end_date = date.end_of_day

				visible_networks = current_user.entity.visible_networks
		    	location_network_list = JqxConverter.jqxDropDownList(visible_networks)

				if params['location_network_id'].nil?
					default_network = visible_networks[0]
				else
					default_network = Network.find(params['location_network_id'])					
				end
				
				facts = AssetLocationNetworkInOutSummaryFact.between(fact_time: start_date..end_date).where(:report_entity => current_user.entity, :location_network => default_network)				
		    	response = {:grid => facts, :location_networks => location_network_list}
		    	 
		    	render json: response
			}
		end
	end	
	def performance_scorecard_report
		respond_to do |format|  
			format.html
		    format.json { 

				date = DateTime.parse(params['date'])

    			start_date = date.beginning_of_day
    			end_date = date.end_of_day
    			
				if params['network_id'].nil?
					params['network_id'] = current_user.entity.visible_networks.first._id
				end
				
				default_network = Network.find(params['network_id'])
				networks = JqxConverter.jqxDropDownList(current_user.entity.visible_networks)

				facts = JqxConverter.jqxGrid(current_user.entity.network_facts.where(:location_network => default_network).between(fact_time: start_date..end_date))
				print facts.to_json
		    	response = {:grid => facts, :networks => networks}
 	 
		    	render json: response		    	
		    	
			}
		end
	end
end
