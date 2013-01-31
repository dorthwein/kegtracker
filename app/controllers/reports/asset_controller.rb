class Reports::AssetController < ApplicationController
	before_filter :authenticate_user!	
# **********************************
# Asset Reports
# **********************************
	def browse    
		respond_to do |format|		
		  	format.html # index.html.erb
		  	format.json { 		  		
			 	gatherer = Gatherer.new current_user.entity
				if current_user.system_admin == 1
					assets = Asset.all
				else
					assets = gatherer.get_assets
				end
				assets = assets.map { |asset| {	
									:entity => asset.entity_description, 
								    :brewery => asset.product_entity_description,
									:tag_value => asset.tag_value, 
									:asset_type => asset.asset_type_description, 
									:asset_status => asset.asset_status_description,
									:product => asset.product_description,
									:location => asset.location_description,
									:location_network => asset.location_network_description,
									:_id => asset._id,
									:last_action_time => (asset.last_action_time.nil? ? ' ' : asset.last_action_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y")), 
									:fill_time => (asset.fill_time.nil? ? ' ' : asset.fill_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y") )
								} 
						}     
				render json: assets 			
			}
		end
	end  
	def browse_row_select
		respond_to do |format|
			format.json {
				gatherer = Gatherer.new(current_user.entity)
				location, product, entity = gatherer.asset_activity_fact_criteria				
				response = []
				AssetActivityFact.where(:asset => params[:_id], :handle_code => 4).any_of(location, product, entity).desc(:fact_time).each do |x|
					date = 	"<div class='life_cycle_select'><b> Fill Date: </b> #{x.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y")} </div>"
					product = 	"<div class='life_cycle_select'> <b> Product: </b> #{x.product.description} </div>"
					brewery = 	"<div class='life_cycle_select'> <b> Brewery: </b> #{x.product.entity.description} </div>"
					location = 	"<div class='life_cycle_select'> <b> Location: </b> #{x.location.description} </div>"
					location_network = 	"<div class='life_cycle_select'> <b> Location Network: </b> #{x.location.network_description} </div>"

					fill_asset_activity_fact = x.fill_asset_activity_fact_id
					response.push({:value => fill_asset_activity_fact, :html => date + product + brewery + ' <br />' + location + location_network})
				end

				render json: response
			}
		end
	end
	def browse_life_cycle_select
		respond_to do |format|
			format.json {
				gatherer = Gatherer.new(current_user.entity)
				location, product, entity = gatherer.asset_activity_fact_criteria				
				transactions = '' 
				response = {}

				transaction_facts = AssetActivityFact.where(:fill_asset_activity_fact_id => params[:fill_asset_activity_fact_id]).any_of(location, product, entity).desc(:fact_time)
				x = transaction_facts.first							

	            x_product = 	"<td> <b> 	Product: 	</b> 	#{x.product.description}	 </td>"
	            x_brewery = 	"<td> <b> 	Brewery: 	</b> 	#{x.product.entity.description} </td>"
	            x_asset_type = 	"<td> <b> 	Asset Type: </b> 	#{x.asset_type.description} </td>"
	            x_entity = 		"<td> <b> 	Owner: 		</b> 	#{x.entity.description} </td>"
	            x_fill_date = 	"<td> <b> 	Fill Date: 	</b> 	#{x.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y")} </td>"

				x_fill_count = 	"<td> <b> 	Fill Count: </b> 	#{x.fill_count} 		</td>"
				x_tag_value = 	"<td> <b> 	Tag Value: 	</b> 	#{x.asset.tag_value} 	</td>"
				x_tag_key = 	"<td> <b> 	Tag Key: 	</b> 	#{x.asset.tag_key} 		</td>"

				# Start Table
				transactions = "<table> <tbody> " 

				# Add Asset Details
				transactions = transactions + "<tr>" + x_product + x_brewery + x_asset_type + x_entity + x_fill_date + " </tr> "
				transactions = transactions + "<tr>" + x_fill_count + x_tag_value + x_tag_key + "<td></td><td></td> </tr> "
				# Activity Header
				transactions = transactions + ' <tr> <td colspan="5"> <h3 style="border-bottom:1px solid #CCC;border-top:1px solid #CCC; margin:10px 0 0 0;"> Activity </h3> </td> </tr>'


				
				transactions = transactions + '<tr>	<th> Action	</th> <th> Location </th> <th> Location Network	</th> <th> Date </th> <th> Transaction Entity </th> </tr>'


				# For each transaction, create a row
				transaction_facts.each do |x|					
					action = 					"<td> #{x.handle_code_description} </td>"
					location = 					"<td> #{x.location.description} </td>"
					location_network = 			"<td> #{x.location.network_description} </td>"
					date = 						"<td> #{x.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y")} </td>"
					transaction_entity = 		"<td> #{x.user.entity.description} </td>"
					fill_asset_activity_fact = 	x.fill_asset_activity_fact_id

					transactions = transactions + '<tr>' + action + location + location_network + date + transaction_entity +  '</tr>'
				end

				response = {:html => transactions}
				render json: response
			}
		end
	end

	def sku_summary_report
		respond_to do |format|  
			format.html
		    format.json { 				
		    	print params['test']
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
