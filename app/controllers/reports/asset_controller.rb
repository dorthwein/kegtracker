class Reports::AssetController < ApplicationController	
	before_filter :authenticate_user!	
	load_and_authorize_resource
# **********************************
# Asset Reports
# **********************************
	def browse    
		respond_to do |format|		
		  	format.html # index.html.erb
		  	format.json { 		  						
				render json: JqxConverter.jqxGrid(current_user.entity.visible_assets)
			}
		end
	end  
	def browse_row_select
		respond_to do |format|
			format.json {
				response = []				
				asset = Asset.find(params[:_id]);
				asset.fill_life_cycles({:entity => current_user.entity}).each do |x|
				#current_user.entity.visible_asset_activity_facts.where(:asset => params[:_id], :handle_code => 4).desc(:fact_time).each do |x|					
					date = 	"<td class='life_cycle_select'><b> Fill Date: </b> #{x.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y")} </td>"
					product = 	"<td class='life_cycle_select'> <b> Product: </b> #{x.product.description} </td>"
					brewery = 	"<td class='life_cycle_select'> <b> Brewery: </b> #{x.product.entity.description} </td>"
					location = 	"<td class='life_cycle_select'> <b> Location: </b> #{x.location.description} </td>"
					location_network = 	"<td class='life_cycle_select'> <b> Location Network: </b> #{x.location.network_description} </td>"
					
					fill_asset_activity_fact = x.fill_asset_activity_fact_id
					response.push({:value => fill_asset_activity_fact, :html => '<table><tbody><tr>' + date + product + brewery + '</tr> <tr>' + location + location_network + '</tr></tbody> </table>'})
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

	def sku_summary_report_advanced
		respond_to do |format|  
			format.html
		    format.json {
		    	if params['date'].nil?
		    		start_date = Time.new() - (14 * 86400)
		    		end_date = Time.new()
		    	else
		    		start_date = DateTime.parse(params['date']['0'])
		    		end_date = DateTime.parse(params['date']['1'])
		    	end
				
				asset_summary_facts = AssetSummaryFact.where(:report_entity => current_user.entity).between(fact_time: start_date..end_date).desc(:fact_time)
				response = asset_summary_facts

		    	render json: response
			}			
		end			
	end

	def sku_summary_report_simple
		respond_to do |format|  
			format.html
		    format.json {
    			if params['date'].nil?
					date = Time.new().in_time_zone("Central Time (US & Canada)")
    			else
					date = DateTime.parse(params['date'])
    			end

    			start_date = date.beginning_of_day
    			end_date = date.end_of_day
    			
#				if params['location_network_id'].nil?
#					default_network = visible_networks[0]
#				else
#					default_network = Network.find(params['location_network_id'])
#				end				
								
				facts = JqxConverter.jqxGrid(current_user.entity.network_facts.between(fact_time: start_date..end_date))
		    	response = {:grid => facts} #, :location_networks => location_network_list}
 	 
		    render json: response
		}
		end			
	end	
end

