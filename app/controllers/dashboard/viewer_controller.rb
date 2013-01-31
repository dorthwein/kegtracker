class Dashboard::ViewerController < ApplicationController
	before_filter :authenticate_user!	
	def index			
		respond_to do |format|  
			format.html	
			format.json { 				
				gatherer = Gatherer.new(current_user.entity)
				location, product, entity = gatherer.asset_activity_fact_criteria

				print params['start_date']
				print params['end_date']
				start_date = DateTime.parse(params['date'])					
				end_date = DateTime.parse(params['date'])
				
				asset_summary_facts = AssetSummaryFact.between(fact_time: start_date.beginning_of_day..end_date.end_of_day).where(:report_entity => current_user.entity)

				# facts = AssetSummaryFact.between(fact_time: (Time.new() - 4325)..(Time.new() + 4325)).any_of(location, product, entity)

				location_networks = asset_summary_facts.group_by{|x| x.location_network}.map{|x| {:location_network_id => x[0]._id, :location_network_description => x[0].description, :checked => true }}				
				products = asset_summary_facts.group_by{|x| x.product}.map{|x| {:product_id => x[0]._id, :product_description => x[0].description, :checked => true }}				
				product_entities = asset_summary_facts.group_by{|x| x.product_entity}.map{|x| {:product_entity_id => x[0]._id, :product_entity_description => x[0].description, :checked => true }}				
				asset_types = asset_summary_facts.group_by{|x| x.asset_type}.map{|x| {:asset_type_id => x[0]._id, :asset_type_description => x[0].description, :checked => true}}				

				# SKU Summary Chart Data
				asset_summary_chart_full_data = []
				asset_summary_chart_market_data = []
				asset_summary_chart_empty_data = []
				asset_summary_chart_settings = {:interval => 10, :max => 5, :min => 0}

				asset_summary_facts.desc(:fact_time).group_by{|x| x.sku_id}.each do |sku|
					full_record = {:sku_description => sku[1][0].sku_description}
					market_record = {:sku_description => sku[1][0].sku_description}
					empty_record = {:sku_description => sku[1][0].sku_description}

					sku[1].each do |fact|
						full_data_fact = {fact.location_network_id => fact.full_quantity}						
						market_data_fact = {fact.location_network_id => fact.market_quantity}						
						empty_data_fact = {fact.location_network_id => fact.empty_quantity}						
						
						asset_summary_chart_settings[:max] < fact.full_quantity ? asset_summary_chart_settings[:max] = fact.full_quantity : nil
						asset_summary_chart_settings[:max] < fact.market_quantity ? asset_summary_chart_settings[:max] = fact.market_quantity : nil
						asset_summary_chart_settings[:max] < fact.empty_quantity ? asset_summary_chart_settings[:max] = fact.empty_quantity : nil

						full_record.merge!(full_data_fact)
						market_record.merge!(market_data_fact)
						empty_record.merge!(empty_data_fact)
					end
					asset_summary_chart_full_data.push(full_record)
					asset_summary_chart_market_data.push(market_record)
					asset_summary_chart_empty_data.push(empty_record)
				end

				# SKU Summary Chart Series
				asset_summary_chart_series = []
				asset_summary_facts.desc(:fact_time).group_by{|x| x.location_network}.each do |location_network|
					fact = {:dataField => location_network[0]._id, :displayText => location_network[0].description }
					asset_summary_chart_series.push(fact)
				end

				# Network Inbound/Outbound Chart Series
				asset_location_network_in_bound_summary_data = []
				asset_location_network_out_bound_summary_data = []
				asset_location_network_in_out_bound_summary_series = []


				asset_location_network_in_out_summary_fact = AssetLocationNetworkInOutSummaryFact.between(fact_time: (start_date.to_time.beginning_of_day.to_i - (14 * 86400))..end_date.to_time.end_of_day.to_i).where(:report_entity => current_user.entity)				
				asset_location_network_in_out_summary_fact.group_by{|x| x.location_network_asset_type_id}.each do |x|
					record = {:dataField => x[0], :displayText => x[1][0].asset_type_description.to_s + ' - ' + x[1][0].location_network_description }
					asset_location_network_in_out_bound_summary_series.push(record)
				end

				asset_location_network_in_out_summary_fact.group_by{|x| x.fact_time.beginning_of_day}.each do |x|
					out_bound_record = {:date => x[0].in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y")}
					in_bound_record = {:date => x[0].in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y")}
					x[1].each do |fact_by_date|
						in_bound_record[fact_by_date.location_network_asset_type_id] = fact_by_date.in_total_quantity + (in_bound_record[fact_by_date.location_network_asset_type_id] || 0)
						out_bound_record[fact_by_date.location_network_asset_type_id] = fact_by_date.out_total_quantity + (out_bound_record[fact_by_date.location_network_asset_type_id] || 0)
					end	
					asset_location_network_in_bound_summary_data.push(in_bound_record)
					asset_location_network_out_bound_summary_data.push(out_bound_record)
				end

				# Recent Activity				
				recent_activity_data = []
				asset_activity_facts = AssetActivityFact.between(fact_time: (start_date.beginning_of_day)..end_date.end_of_day).any_of(location, product, entity).desc(:fact_time)
				asset_activity_facts.each do |x|
					
					date = 				"<div style='float:left;'><b> Time: </b> #{x.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%l:%M %p - %b %d, %Y")} </div>"
					action = 			"<div style='float:left;'> <b> Action: </b> #{x.handle_code_description} </div>"
					product = 			"<div style='float:left;'> <b> Product: </b> #{x.product.description} - #{x.asset_type.description} </div>"
					brewery = 			"<div style='float:left;'> <b> Brewery: </b> #{x.product.entity.description} </div>"
					location = 			"<div style='float:left;'> <b> Location: </b> #{x.location.description} </div>"
					location_network = 	"<div style='float:left;'> <b> Location Network: </b> #{x.location.network.description} </div>"
					
					recent_activity_data.push({:html => '<div style="float:left; width:250px; margin-left:25px;">' +  action + ' <br />' + product + ' <br />' + location + '</div> <div style="float:left;width:250px; max-width:250px">' + date + ' <br />' +  brewery + ' <br />' + location_network + '</div>' })

					
				    
				end

				render json: { 	
								:location_networks => location_networks, 
								:products => products, 
								:product_entities => product_entities,
								:asset_types => asset_types,
								:asset_summary_chart_series => asset_summary_chart_series,
								:asset_summary_chart_full_data => asset_summary_chart_full_data,
								:asset_summary_chart_market_data => asset_summary_chart_market_data,
								:asset_summary_chart_empty_data => asset_summary_chart_empty_data,
								:asset_summary_chart_settings => asset_summary_chart_settings,
								:asset_location_network_in_bound_summary_data => asset_location_network_in_bound_summary_data,
								:asset_location_network_out_bound_summary_data => asset_location_network_out_bound_summary_data,
								:asset_location_network_in_out_bound_summary_series => asset_location_network_in_out_bound_summary_series,
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
