module ApplicationHelper
	def report_select_menu

html = <<select_box
		<div style="float:right; padding:10px">
			<label style="font-size:14px; font-weight:bolder"> Reports </label> <br />
			<select id="report_select_menu" class="select_menu link">	
				<optgroup label="Asset Reports">				
				


					<option value="#{reports_assets_url}" class="indent"> 
						Asset Report				
					</option>
				
					<option value="#{reports_assets_sku_summary_report_simple_url}" class="indent"> 
						Inventory By SKU Summary Report
					</option>
					
					<option value="#{reports_overdue_assets_url}" class="indent"> 
						Overdue Asset Return Report		
					</option>


					<option value="#{reports_float_activity_summary_report_simple_url}" class="indent"> 
						Daily Scan Activity Summary Report
					</option>
					<option value="#{reports_float_asset_fill_to_fill_cycle_fact_by_fill_network_url}" class="indent"> 
						Asset Cycle Summary by SKU by Production Channel Report 
					</option>
					<option value="#{reports_float_asset_fill_to_fill_cycle_fact_by_delivery_network_url}" class="indent"> 
						Asset Cycle Summary by SKU by Distribution Channel Report 
					</option>
					<option value="#{reports_asset_cycles_url}" class="indent"> 
						Active Asset Cycles Report
					</option>
					<option value="#{reports_completed_asset_cycles_url}" class="indent"> 
						Completed Asset Cycles Report
					</option>
				</optgroup>
				
				
				<optgroup label="Invoice">
					<option value="#{accounting_invoices_url}" class="indent">  
						Invoice Manifests
					</option>
				</optgroup>

				<optgroup label="Location Reports">
					<option value="#{reports_locations_url}" class="indent">  
						Locations Report
					</option>
				</optgroup>
			</select>
		</div>
		<div style="clear:both"></div>
select_box


		return html.html_safe # .to_s
	end
	def public_menu
html = <<html
		<table>
			<tbody>
				<tr>						
					<td>	
						#{link_to image_tag("public_home_icon.png"), :public_home}
						<h5> Home	</h5>
					</td>
					<td>								
						#{link_to image_tag("abouticon.png"), :public_about_keg_tracker}							
						<h5> FAQ	</h5>
					</td>

					<td>
						#{link_to image_tag("products_icon.png"), :public_products}
						<h5> Products	</h5>
					</td>

					<td>	
						#{link_to image_tag("playicon.png"), new_user_session_path}
						<h5> Demo	</h5>
					</td>

					<td>	
						#{link_to image_tag("join_icon.png"), :public_join_index}
						<h5> Sign Up	</h5>
					</td>

				</tr>
			</tbody>
		</table>
html

	return html.html_safe
	end
end

#	value="#{accounting_invoices_url}"
#	value="#{reports_assets_url}"
#	value="#{reports_locations_url}"
#	value="#{reports_asset_cycles_url}"
#	value="#{reports_completed_asset_cycles_url}"
#	value="#{reports_float_asset_fill_to_fill_cycle_fact_by_delivery_network_url}"
#	value="#{reports_float_asset_fill_to_fill_cycle_fact_by_fill_network_url}"
#	value="#{reports_float_activity_summary_report_simple_url}"
#	value="#{reports_overdue_assets_url}"
#	value="#{reports_network_performance_scorecard_report_url}"
#	value="#{reports_assets_sku_summary_report_simple_url}"	
=begin
# Maintenance
	value="#{maintenance_locations_url}"
	value="#{maintenance_networks_url}"
	value="#{maintenance_distribution_partnerships_url}"
	value="#{maintenance_products_url}"
	value="#{maintenance_skus_url}"
	value="#{maintenance_users_url}"
=end