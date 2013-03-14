class Reports::LocationController < ApplicationController
  	before_filter :authenticate_user!
  	load_and_authorize_resource

	def browse    
		respond_to do |format|		
		  	format.html # index.html.erb
		  	format.json { 
				locations = JqxConverter.jqxGrid(current_user.entity.locations)
				render json: locations
		  	}
		end
	end
	def browse_row_select
		respond_to do |format|
			format.json {
				response = []
				current_user.entity.visible_assets.where(location_id: params[:_id]).each do |x|
					fill_time = 		"<div> <b> Fill Date: 			</b>	 #{x.fill_time ? x.fill_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y") : ''} </div>"
					last_scene_time = 	"<div> <b> Last Scene: 			</b>	 #{x.last_action_time ? x.last_action_time.in_time_zone("Central Time (US & Canada)").strftime("%l:%M %p, %Z - %b %d, %Y") : ''} </div>"
					product = 			"<div> <b> Product: 			</b>	 #{x.product_description}			</div>"
					brewery = 			"<div> <b> Brewery: 			</b>	 #{x.product_entity_description} 	</div>"
					entity = 			"<div> <b> Asset Owner: 		</b>	 #{x.entity.description} 			</div>"
					asset_type =	 	"<div> <b> Asset Type: 			</b>	 #{x.asset_type_description} 		</div>"
					location = 			"<div> <b> Location: 			</b>	 #{x.location_description} 			</div>"
					location_network = 	"<div> <b> Location Network: 	</b>	 #{x.location.network_description} 	</div>"
	
				#	fill_asset_activity_fact = x.fill_asset_activity_fact_id	
					response.push({:value => x._id, :html => '<div style="float:left; width:40%;">' +  product + asset_type + location + last_scene_time  + "</div>" + "<div style='width:40%;float:left'>" +   brewery + entity +  location_network + fill_time + "</div>" })
				end

				render json: response
			}
		end
	end
	def browse_asset_select
		respond_to do |format|
			format.json {
				response = {}
				asset = Asset.find(params[:asset_id])
				
				x = asset.asset_cycle_fact.start_asset_activity_fact rescue nil
				if !x.nil?
		            x_product = 	"<td> <b> 	Product: 	</b> 	#{x.product.description}	 </td>"
		            x_brewery = 	"<td> <b> 	Brewery: 	</b> 	#{x.product.entity.description} </td>"
		            x_asset_type = 	"<td> <b> 	Asset Type: </b> 	#{x.asset_type.description} </td>"
		            x_entity = 		"<td> <b> 	Owner: 		</b> 	#{x.entity.description} </td>"
		            x_fill_date = 	"<td> <b> 	Fill Date: 	</b> 	#{x.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y")} </td>"

					x_fill_count = 	"<td> <b> 	Fill Count: </b> 	#{x.fill_count} 		</td>"
					x_tag_value = 	"<td> <b> 	Tag Value: 	</b> 	#{x.asset.tag_value} 	</td>"
					x_tag_key = 	"<td> <b> 	Tag Key: 	</b> 	#{x.asset.tag_key} 		</td>"

					# Start Table
					transactions = "<table> <tbody>" 

					# Add Asset Details
					transactions = transactions + "<tr>" + x_product + x_brewery + x_asset_type + x_entity + x_fill_date + " </tr> "
					transactions = transactions + "<tr>" + x_fill_count + x_tag_value + x_tag_key + "<td></td>	<td></td> </tr>"
					# Activity Header
					transactions = transactions + ' <tr> <td colspan="5"> <h3 style="border-bottom:1px solid #CCC;border-top:1px solid #CCC; margin:10px 0 0 0;"> Activity </h3> </td> </tr>'


					
					transactions = transactions + '<tr>	<th> Action	</th> <th> Location </th> <th> Location Network	</th> <th> Date </th> <th> Transaction Entity </th> </tr>'

					# For each transaction, create a row
					asset.asset_cycle_fact.asset_activity_facts.each do |x|					
						action = 					"<td> #{x.handle_code_description} </td>"
						location = 					"<td> #{x.location.description} </td>"
						location_network = 			"<td> #{x.location.network_description} </td>"
						date = 						"<td> #{x.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y")} </td>"
						transaction_entity = 		"<td> #{x.user.entity.description} </td>"
	#					fill_asset_activity_fact = 	x.fill_asset_activity_fact_id

						transactions = transactions + '<tr>' + action + location + location_network + date + transaction_entity +  '</tr>'
					end
				else
					transactions = 'No Asset History Found'
				end

				response = {:html => transactions}
				render json: response
			}
		end
	end
end
