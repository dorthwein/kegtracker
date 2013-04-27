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
						<h6> Home	</h5>
					</td>
					<td>								
						#{link_to image_tag("abouticon.png"), :public_about_keg_tracker}							
						<h6> FAQ	</h5>
					</td>

					<td>
						#{link_to image_tag("products_icon.png"), :public_products}
						<h6> Products	</h5>
					</td>

					<td id="demo_link">	
						#{link_to image_tag("playicon.png"), new_user_session_path}
						<h6> Demo	</h5>
					</td>

					<td>	
						#{link_to image_tag("join_icon.png"), :public_join_index}
						<h6> Sign Up	</h5>
					</td>

				</tr>
			</tbody>
		</table>
html

	return html.html_safe
	end

	def main_menu
		if user_signed_in? && current_user.system_admin == 1
system = <<html			
			<li> System 
				<ul>
					<li> #{link_to 'Entities', :system_entities } </li>
					<li> #{link_to 'Registrations', :system_registrations } </li>
					<li> Networks (Disabled) </li>
					<li> #{link_to 'Entity Types', :system_entity_types } </li>
					<li> #{link_to 'Product Types', :system_product_types } </li>
					<li> #{link_to 'Asset Types', :system_asset_types } </li>
					<li> #{link_to 'Unit Sizes', :system_measurement_units } </li>
					<li> #{link_to 'Asset State', :system_asset_states } </li>
					<li> #{link_to 'Handle Codes', :system_handle_codes } </li>
				</ul>
			</li>							
html
		end 
		if !user_signed_in?
html = <<html
		<div id="header" style="top:0; left: 0; height:30px; width:100%;">			
	        <div id="jqxMenu">
	            <ul>    	            
					<li> #{link_to 'Log in', new_user_session_path } </li>								
				</ul>
			</div>
		</div>
html
		else
html = <<html
		<div id="header" style="top:0; left: 0; height:30px; width:100%;">						
			<div id="jqxMenu">
	            <ul>                					
					<li>
						Home
						<ul>
							<li> #{link_to 'Dashboard', :dashboard_viewer } </li>
							<li> #{link_to 'Account', :account_profiles }   </li>
							<li> #{link_to 'Sign out', destroy_user_session_path, :method => :delete } </li>
						</ul>					
					</li>					
					<li> 
						Reporting 
						<ul>
							<li> 	
								Invoices
								<ul>
									<li> 
										#{link_to 'Lookup', :accounting_invoices }  
									</li>
								</ul>
							</li>

							<li> 	
								Assets
								<ul>
									<li>
										#{link_to 'Assets Report', :reports_assets }
									</li>

									<li>
										#{link_to 'Overdue Assets Report', :reports_assets }
									</li>

									<li>
										#{link_to 'Inventory By SKU Summary Report', :reports_assets_sku_summary_report_simple }
									</li>
									<li>
										#{link_to 'Active Asset Cycles', :reports_asset_cycles }
									</li>

									<li>
										#{link_to 'Completed Asset Cycles', :reports_completed_asset_cycles }
									</li>

								</ul>							
							</li>

							<li> 	
								Locations
								<ul>
									<li>
										#{link_to 'Browse', :reports_locations }
									</li>
								</ul>							
							</li>
							<li style="display:none;"> 	
								Network
								<ul>
									<li>
										#{link_to 'Performance Scorecard', :reports_network_performance_scorecard_report } 																		
									</li>
								</ul>							
							</li>
								
							<li> 	
								Activity
								<!-- Broad float wide reporting --> 
								<ul>
									<li>
										#{link_to 'Asset Cycle Summary by SKU by Distribution Channel Report', :reports_float_asset_fill_to_fill_cycle_fact_by_delivery_network } 
									</li>


									<li>
										#{link_to 'Asset Cycle Summary by SKU by Production Channel Report', :reports_float_asset_fill_to_fill_cycle_fact_by_fill_network } 
									</li>
									<li>
										#{link_to 'Daily Scan Activity Summary Report', :reports_float_activity_summary_report_simple } 									
									</li>
									
								</ul>							
							</li>							
						</ul>
					</li>					
					<li> 
						Scanners
						<ul>	
							<li> #{link_to 'Barcode Scanner', :scanners_barcode } </li>
							<li> #{link_to 'RFID Readers', :scanners_rfid_readers } </li>
							<li> #{link_to 'Invoice Manifest', :accounting_invoices } </li>

						</ul>							
					</li>
					<li> 
						Maintenance
						<ul>
							<li> #{link_to 'Users', :maintenance_users } </li>
							<li>
								Distribution
								<ul>
									<li> #{link_to 'Distributors', :maintenance_distribution_partnerships } </li>
										<!-- Breweries allows to produce my beers -->
									<li style="display:none"> #{link_to 'Brewery Partners', :maintenance_distribution_partnerships } 
									</li>
								</ul>
							</li>
							<li>
								Products
								<ul>
									<li> #{link_to 'SKUs', :maintenance_skus } 
									</li>		

									<li> #{link_to 'Products', :maintenance_products } 
									</li>				
									<li> 										
										#{link_to 'Contract Breweries', :maintenance_production_partnerships } 
									</li>		
								</ul>
							<li> 
								Locations
								<ul>
									<li> #{link_to 'Networks', :maintenance_networks } </li>
									<li> #{link_to 'Locations', :maintenance_locations } </li>
								</ul>
							</li>
							<li>
								Scanning
								<ul>
									<li> #{link_to 'Print Barcodes', :new_maintenance_barcode_maker } </li>
									<li> #{link_to 'RFID', :maintenance_rfid_readers } </li>
								</ul>
							</li>	
						</ul>
					</li>
					#{system}
					<div style="float:right; width:33%; text-align:right; padding:5px 0px 5px 0px;" class="right"> 
						<span style="margin-right:30px">#{current_user.email } </span>
					</div>
				</ul>				
			</div>
			
	        
			<div style="clear:both"> </div>	
		</div>
html
		end
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