module ApplicationHelper
	def report_select_menu

html = <<select_box
		<div style="float:right; padding:10px">
			<!-- <label style="font-size:14px; font-weight:bolder"> Reports </label> <br /> -->
			<select id="report_select_menu" class="select_menu link">	
				<optgroup label="Asset Reports">				
					<option value="#{maintenance_assets_url}" class="indent"> 
						Asset Maintenance				
					</option>
				
					<option value="#{reports_assets_sku_summary_report_simple_url}" class="indent"> 
						Inventory By SKU Summary Report
					</option>
					
					<option value="#{maintenance_overdue_assets_url}" class="indent"> 
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
					<option value="#{maintenance_asset_cycles_url}" class="indent"> 
						Active Asset Cycles Report
					</option>
					<option value="#{maintenance_completed_asset_cycles_url}" class="indent"> 
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
						#{link_to image_tag("mailicon.png"), :public_contact}
						<h6> Contact	</h5>
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
	def web_app_menu
html = <<html
		<div id="header" style="display:none;">
			<div style="text-align:left; width:40%; float:left;">
				 #{current_user.entity.description}	
			</div>
			<div style="text-align:right; width:40%; float:right;">
				#{ link_to image_tag('brewery_apps_logo.png', :style => 'height:25px;'), :public_home }
			</div>
		</div>
html
		return html.html_safe
	end

	def display_menu
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
		<div id="header" style="">			
	        <div id="jqxMenu">
	            <ul>    	            
					<li> #{link_to 'Log in', new_user_session_path } </li>								
				</ul>
			</div>
		</div>
html
		else
html = <<html
		<div id="header">						
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
								Assets
								<ul>
									<li>
										#{link_to 'Inventory By SKU Summary Report', :reports_assets_sku_summary_report_simple }
									</li>

									<li>
										#{link_to 'Asset Cycle Summary by SKU by Distribution Channel Report', :reports_float_asset_fill_to_fill_cycle_fact_by_delivery_network } 
									</li>

									<li>
										#{link_to 'Asset Cycle Summary by SKU by Production Channel Report', :reports_float_asset_fill_to_fill_cycle_fact_by_fill_network } 
									</li>

								</ul>
							</li>

							<li> 	
								Locations
								<ul>
									<li>

									</li>
								</ul>							
							</li>
							<li> 	
								Network
								<ul>
									<li>

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
										#{link_to 'All Assets', :maintenance_assets }
									</li>						

									<li>
										#{link_to 'Overdue Assets', :maintenance_overdue_assets }
									</li>

									<li>
										#{link_to 'Active Asset Cycles', :maintenance_asset_cycles }
									</li>
									<li>
										#{link_to 'Compelted Asset Cycles', :maintenance_completed_asset_cycles }
									</li>
								</ul>							
							</li>
							<li>
								Distribution
								<ul>
									<li> #{link_to 'Distributors', :maintenance_distribution_partnerships } </li>
										<!-- Breweries allows to produce my beers -->
									<li style="display:none"> #{link_to 'Brewery Partners', :maintenance_distribution_partnerships } 
									</li>
								</ul>
							</li>
							
								
						
							<li> #{link_to 'SKUs', :maintenance_skus } </li>		

							<li> #{link_to 'Products', :maintenance_products } </li>				
								Locations
								<ul>
									<li> #{link_to 'Networks', :maintenance_networks } </li>
									<li> #{link_to 'Locations', :maintenance_locations } </li>
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

	def side_navigation_bar
html = <<html
	    <div class="full sidebar">
	        <div class="section first"> 
				#{ link_to image_tag('brewery_apps_logo.png', :style => 'width:58px;margin:auto;'), :dashboard_viewer }	        				
	        </div>


	        <div class="section"> 				
				<h4 class="title"> #{ link_to 'Home', :dashboard_viewer }  </h4>
	        </div>

	        <div class="section"> 				
				<h4 class="title">  #{ link_to 'Account', :account_profiles }  </h4>
	        </div>
	        <div class="section"> 				
				<h4 class="title"> #{ link_to 'Scanner', :scanners_barcode }  </h4>
	        </div>

	        <div class="section expandable"> 
	            <h4 class="title"> Reports </h4> 
	            <div class="content">   
	                <ul>   

	                    <li class="expandable">
	                        <div class="title"> Assets </div>
	                        <ul class="content">
	                        	<!-- Inventory Count over time # summation of assets then can add dimensions -->
									<li> #{link_to 'Overview', :reports_assets_overview_index } </li>

								<!-- Losses -->
									<li> #{link_to 'Loss', :reports_float_asset_fill_to_fill_cycle_fact_by_delivery_network }  </li>
								
								<!-- # Assets Overdue -->
									<li> #{link_to 'Overdue', :reports_float_asset_fill_to_fill_cycle_fact_by_fill_network }  </li>

								<!-- Asset Flow -->
									<li> #{link_to 'Flow', :reports_float_asset_fill_to_fill_cycle_fact_by_delivery_network }  </li>
	                        </ul>
	                    </li>


	                    <li class="expandable">    
	                        <div class="title"> Asset Cycles </div>
	                        <ul class="content">	                        
									<li> #{link_to 'Overview', :reports_assets_sku_summary_report_simple } </li>
									
									<li> #{link_to '', :reports_float_asset_fill_to_fill_cycle_fact_by_fill_network }  </li>
	                        </ul>
	                    </li>
	                </ul>
	            </div>
	        </div>

	        <div class="section expandable"> 
	            <h4 class="title"> Maintenance </h4> 
	            <div class="content">   
	                <ul>   
	                    <li>    #{ link_to 'Users', :maintenance_users }    </li>
	                    <li>    #{ link_to 'Invoices', :accounting_invoices }  </li>

	                    <li class="expandable">    
	                        <div class="title"> Assets </div>
	                        <ul class="content">
	                            <li>  #{ link_to 'All', :maintenance_assets } </li>
	                            <li>  #{ link_to 'Overdue', :maintenance_overdue_assets } </li>
	                            <li>  #{ link_to 'Active Cycles', :maintenance_asset_cycles } </li>
	                            <li>  #{ link_to 'Completed Cycles', :maintenance_completed_asset_cycles } </li>
	                        </ul>
	                    </li>

	                    <li>    #{ link_to 'Distributors', :maintenance_distribution_partnerships }  </li>  

	                    <li>    #{ link_to 'Contract Brewers', :maintenance_production_partnerships }  </li>  


                        <li>  #{ link_to 'Products', :maintenance_products } </li>
                        <li>  #{ link_to 'SKUs', :maintenance_skus } </li>                            

	                    <li>    #{ link_to 'Locations', :maintenance_locations }  </li>  
	                    <li>    #{ link_to 'Networks', :maintenance_networks }  </li>                     
	                </ul>
	            </div>            
	        </div>
	        

	        <div class="section"> 				
				<h4 class="title"> #{link_to 'Sign out', destroy_user_session_path, :method => :delete } </h4>
	        </div>
	        
	    </div>

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