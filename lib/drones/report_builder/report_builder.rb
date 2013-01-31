=begin
class ReportBuilder < ApplicationController
	def initialize
		
	end	
#	handle_asynchronously :initialize
	
	def check_date_dimension(day = Date.today)
		date = DateDimension.where(:day_of_year => day.yday, :year => day.year).first

# **********************************
# Check/Creation DateDimension
# **********************************
		if date.nil?
			date = DateDimension.create(
				:created_at => day,
				:day_of_year => day.yday,
				:day_of_month => day.mday,
				:day_of_week => day.cwday,
				:day_of_week_description => day.strftime("%a"),
				:month_of_year => day.month,
				:month_description => day.strftime('%b'),
				:year => day.year
			)
		end						
	end

# **********************************
# Daily Activity Report Build
# **********************************
	def daily_activity_report_build(day = Date.today)
		check_date_dimension(day)

		date = DateDimension.where(:day_of_year => day.yday, :year => day.year).first
		
		asset_types = Array.new
		asset_types = asset_types.push(nil) + AssetType.all
		
		networks = Array.new
		networks = networks.push(nil) + Network.all
			
		products = Array.new
		products = products.push(nil) + Product.all


		Entity.all.each do |entity|
			DailyAssetActivityReportFact.destroy_all(:date_dimension => date, :entity => entity)		
			gatherer = Gatherer.new entity
			assets = gatherer.get_assets
			networks.each do |network|				
				products.each do |product|
					asset_types.each do |asset_type|
						handle_code = HandleCode.where(:code => 1).first						
						delivery_count =  AssetActivityFact.where(		:asset.in => assets,
																		:product => product,
																		:asset_type => asset_type,
																		:handle_code => handle_code,
																		:location_network => network,
																		:date_dimension => date
						).count
	
						handle_code = HandleCode.where(:code => 2).first					
						pickup_count =  AssetActivityFact.where(		:asset.in => assets,
																		:product => product, 
																		:asset_type => asset_type, 
																		:handle_code => handle_code, 
																		:location_network => network,
																		:date_dimension => date
						).count
						
						handle_code = HandleCode.where(:code => 4).first
						fill_count =  AssetActivityFact.where(			:asset.in => assets,
																		:product => product, 
																		:asset_type => asset_type, 
																		:handle_code => handle_code, 
																		:location_network => network,
																		:date_dimension => date
						).count
	
						handle_code = HandleCode.where(:code => 5).first					
						move_count =  AssetActivityFact.where(			:asset.in => assets,
																		:product => product, 
																		:asset_type => asset_type, 
																		:handle_code => handle_code, 
																		:location_network => network,
																		:date_dimension => date
						).count
						if delivery_count > 0 || pickup_count > 0 || fill_count > 0 || move_count > 0						
	
							DailyAssetActivityReportFact.create(
														:entity => entity,
														:date_dimension => date,
	
														:network => network,														
														:asset_type => asset_type,
														:product => product,
	
														:delivery => delivery_count,
														:pickup => pickup_count,
														:fill => fill_count,
														:move => move_count
							)
							
						end						
					end
				end
			end
		end
	end	
	handle_asynchronously :daily_activity_report_build			

# **********************************
# Dailey Asset Summary Report Build
# **********************************	
	def daily_asset_summary_report_build(day = Date.today)
		check_date_dimension(day)

		date = DateDimension.where(:day_of_year => day.yday, :year => day.year).first
		
		asset_types = Array.new
		asset_types = asset_types.push(nil) + AssetType.all
			
		products = Array.new
		products = products.push(nil) + Product.all
		
		networks = Array.new
		networks = networks.push(nil) + Network.all
				
		asset_state_empty = AssetState.where(:description => 'Empty').first						
		asset_state_market = AssetState.where(:description => 'Market').first								
		asset_state_full = AssetState.where(:description => 'Full').first	
		
		Entity.all.each do |entity|
			DailyAssetSummaryReportFact.destroy_all(:date_dimension => date, :entity => entity)
			gatherer = Gatherer.new entity			
			assets = gatherer.get_assets

			networks.each do |network|																							
				products.each do |product|					
					asset_types.each do |asset_type|
					
						full = Asset.where(:_id.in => assets, :location_network => network, :product => product, :asset_type => asset_type, :asset_state => asset_state_full).count					
						market = Asset.where(:_id.in => assets, :location_network => network, :product => product, :asset_type => asset_type, :asset_state => asset_state_market).count	
						empty = Asset.where(:_id.in => assets, :location_network => network, :product => product, :asset_type => asset_type, :asset_state => asset_state_empty).count						
						
						if market > 0 || full > 0 || empty > 0
							DailyAssetSummaryReportFact.create(
								:entity => entity,
								:network => network,
								:product => product,
		
								:asset_type => asset_type,
								:date_dimension => date,
		
								:full => full,
								:market => market,
								:empty => empty,
							)							
						end
					end
				end				
			end
		end
	end	
	handle_asynchronously :daily_asset_summary_report_build
	
# ********************************************
# Dailey Asset Network Movement Report Build
# ********************************************
	# *************
	# INCOMPLETE
	# *************
=begin
	def daily_asset_network_movement_report_fact_build(day = Date.today)
		check_date_dimension(day)
		date = DateDimension.where(:day_of_year => day.yday, :year => day.year).first
		
		asset_types = Array.new
		asset_types = asset_types.push(nil) + AssetType.all
			
		products = Array.new
		products = products.push(nil) + Product.all
		
		networks = Array.new
		networks = networks.push(nil) + Network.all
				
		asset_states = Array.new
		asset_states = asset_states.push(nil) + AssetState.all
		
		Entity.all.each do |entity|
			DailyAssetNetworkMovementReportFact.destroy_all(:date_dimension => date, :report_entity => entity)
			gatherer = Gatherer.new entity

			asset_network_movement_facts = gatherer.get_asset_network_movement_fact			
			networks.each do |network|
				products.each do |product|
					asset_types.each do |asset_type|						
						asset_states.each do |asset_state|
							# Inbound Traffic
							in_bound = AssetNetworkMovementFact.where( 	
																		:_id.in => asset_network_movement_facts,
																		:entry_location_network => network,
																		:product => product,																		
																		:asset_type => asset_type,
																		:entry_location_network_asset_state => asset_state,
																		:entry_location_network_date => date																		
																	).count
							out_bound = AssetNetworkMovementFact.where( 	
																		:_id.in => asset_network_movement_facts,
																		:exit_location_network => network,
																		:product => product,
																		:asset_type => asset_type,																
																		:exit_location_network_asset_state => asset_state,
																		:exit_location_network_date => date,
																	).count																				
							if in_bound > 0 || out_bound > 0
								DailyAssetNetworkMovementReportFact.create(	:report_entity => entity,
																		:network => network,
																		:date_dimension => date,
	
																		:product => product,
																		:asset_state => asset_state,
																		:asset_type => asset_type,
	
																		:in_bound => in_bound,
																		:out_bound => out_bound																	
																	)
							end							
						end
					end
				end				
			end
		end
	end	
	
#	handle_asynchronously :daily_asset_network_movement_report_fact_build
end
=end