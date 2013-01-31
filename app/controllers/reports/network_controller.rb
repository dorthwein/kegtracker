class Reports::NetworkController < ApplicationController
	before_filter :authenticate_user!	
# *****************************************
# Network Reports
# *****************************************
	#Incomplete
	def in_out_asset_report
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
	def performance_scorecard_report
		respond_to do |format|  
			format.html
		    format.json { 
		    	render json: @response 
			}			
		end			
	end	
end
