class Dashboard::ViewerController < ApplicationController
	before_filter :authenticate_user!	
	layout "web_app"
	def index			
		respond_to do |format|  
			format.html	
			format.json { 				
				gatherer = Gatherer.new(current_user.entity)
				location, product, entity = gatherer.asset_activity_fact_criteria
				# Recent Activity				
				recent_activity_data = []
				asset_activity_facts = AssetActivityFact.between(fact_time: (Time.new().beginning_of_day)..Time.new().end_of_day).any_of(location, product, entity).desc(:fact_time)
				asset_activity_facts.each do |x|
					
					date = 				"<div style='float:left;'><b> Time: </b> #{x.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%l:%M %p - %b %d, %Y")} </div>"
					action = 			"<div style='float:left;'> <b> Action: </b> #{x.handle_code_description} </div>"
					product = 			"<div style='float:left;'> <b> Product: </b> #{x.product.description} - #{x.asset_type.description} </div>"
					brewery = 			"<div style='float:left;'> <b> Brewery: </b> #{x.product.entity.description} </div>"
					location = 			"<div style='float:left;'> <b> Location: </b> #{x.location.description} </div>"
					location_network = 	"<div style='float:left;'> <b> Location Network: </b> #{x.location.network.description} </div>"
					
					recent_activity_data.push({:html => '<div style="float:left; width:480px; margin-left:25px;">' +  action + ' <br />' + product + ' <br />' + location + '</div> <div style="float:left;width:400px;">' + date + ' <br />' +  brewery + ' <br />' + location_network + '</div>' })

					
				    
				end

				render json: { 	
								:recent_activity_data => recent_activity_data
							}
			}
		end	
	end
	def current_sku_quantities
		respond_to do |format|  
			format.html
		    format.json { 				
				@response = AssetSummaryFact.where(:report_entity => current_user.entity).desc(:fact_time).map { |asset_summary_fact| {
																						:date => asset_summary_fact.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y"),
																						:location_network => asset_summary_fact.location_network_description,
																						:asset_type => asset_summary_fact.asset_type_description,
																						:sku => asset_summary_fact.sku_description,		
																						:sku_id => asset_summary_fact.sku_id,
																						:date_id => asset_summary_fact.fact_time.to_i,
																						:product => asset_summary_fact.product_description,
																						:product_entity => asset_summary_fact.product_entity_description,
																						:empty_quantity => asset_summary_fact.empty_quantity,
																						:full_quantity => asset_summary_fact.full_quantity,
																						:market_quantity => asset_summary_fact.market_quantity,
																						
																					}
																				}
		    render json: @response
		}			
		end		
	end
end
