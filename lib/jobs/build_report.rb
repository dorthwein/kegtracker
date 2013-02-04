class BuildReport
	attr_accessor :date
	
	def initialize(report_date = Time.now)
		@date = report_date #.beginning_of_day
	end
# **************************************
# Asset Summary Report Build
# **************************************
	def asset_summary_fact
		first_date = @date.end_of_day - (86400 * 365)
		last_date = @date.end_of_day
		
		print @date.beginning_of_day.to_s + " <-- Start of Day \n"
		print @date.end_of_day.to_s + " <-- End of Day \n"
		print @date.to_s + " <-- Report Date \n\n"

		Entity.all.each do |entity|
			AssetSummaryFact.between(fact_time: @date.beginning_of_day..@date.end_of_day).where(:report_entity => entity).delete

#			gatherer = Gatherer.new(entity)			

#			location_network, product, asset_entity = gatherer.asset_activity_fact_criteria
			
			# AssetActivityFact.between(fact_time: last_date..first_date).any_of(location_network, product, asset_entity ).desc(:fact_time)

			facts = entity.asset_activity_facts.between(fact_time: first_date..last_date).desc(:fact_time)

			facts.group_by {|asset_activity_fact| asset_activity_fact.asset_id }.each do |asset_activity_fact_by_asset|
				asset_activity_fact = asset_activity_fact_by_asset[1].first
				# Asset Summary Fact
				if !asset_activity_fact.nil?						
					# Find existing Asset Summary Fact
					asset_summary_fact = AssetSummaryFact.where(	
												:report_entity => entity,												
												:location_network => asset_activity_fact.location_network,
												:product => asset_activity_fact.product,
												:asset_type => asset_activity_fact.asset_type
											).between(fact_time: @date.beginning_of_day..@date.end_of_day).first

					# If found - add to fact
					if !asset_summary_fact.nil?
						
						case asset_activity_fact.asset_status.to_i
						when 0 # Empty
							asset_summary_fact.empty_quantity = asset_summary_fact.empty_quantity.to_i + 1
						when 1 # Full
							asset_summary_fact.full_quantity = asset_summary_fact.full_quantity.to_i + 1

						when 2 # Market
							asset_summary_fact.market_quantity = asset_summary_fact.market_quantity.to_i + 1

						end						
						asset_summary_fact.save!
						
					
					# Else, create new one
					else
						asset_summary_fact = AssetSummaryFact.new(	
												:report_entity => entity,
												:fact_time => @date,
												:location_network => asset_activity_fact.location_network,
												:product => asset_activity_fact.product,
												:asset_type => asset_activity_fact.asset_type,
												:empty_quantity => 0,	
												:full_quantity => 0,
												:market_quantity => 0
											)

						case asset_activity_fact.asset_status.to_i
						when 0 # Empty
							asset_summary_fact.empty_quantity = asset_summary_fact.empty_quantity.to_i + 1

						when 1 # Full
							asset_summary_fact.full_quantity = asset_summary_fact.full_quantity.to_i + 1

						when 2 # Market
							asset_summary_fact.market_quantity = asset_summary_fact.market_quantity.to_i + 1

						end						
						asset_summary_fact.save!
					end					
				end
			end				
		end	
	end
	handle_asynchronously :asset_summary_fact	

# **************************************
# Asset Activity Summary Report Build
# **************************************
	def asset_activity_summary_fact		
		first_date = @date.beginning_of_day
		last_date = @date.end_of_day

		print @date.beginning_of_day.to_s + " <-- Start of Day \n"
		print @date.end_of_day.to_s + " <-- End of Day \n"
		print @date.to_s + " <-- Report Date \n\n"

		Entity.all.each do |entity|
			AssetActivitySummaryFact.between(fact_time: first_date..last_date).where(:report_entity => entity).delete
			
#			gatherer = Gatherer.new entity
#			location_network, product, asset_entity = gatherer.asset_activity_fact_criteria
			
			facts = entity.asset_activity_facts.between(fact_time: first_date..last_date).desc(:fact_time)
			# AssetActivityFact.between(fact_time: @date.beginning_of_day..@date.end_of_day).any_of( location_network, product, asset_entity )
			facts.each do |asset_activity_fact|
				asset_activity_summary_fact = AssetActivitySummaryFact.where(	
											:report_entity => entity,
											:location_network => asset_activity_fact.location_network,
											:product => asset_activity_fact.product,
											:asset_type => asset_activity_fact.asset_type,
#											:asset_status => asset_activity_fact.asset_status,
											:handle_code => asset_activity_fact.handle_code
										).between(fact_time: @date.beginning_of_day..@date.end_of_day).first

				if !asset_activity_summary_fact.nil?
					asset_activity_summary_fact.quantity = asset_activity_summary_fact.quantity + 1
					asset_activity_summary_fact.save!
				else
					AssetActivitySummaryFact.create(
											:report_entity => entity,
											:fact_time => @date,
											:location_network => asset_activity_fact.location_network,
											:product => asset_activity_fact.product,
											:asset_type => asset_activity_fact.asset_type,
#											:asset_status => asset_activity_fact.asset_status,
											:handle_code => asset_activity_fact.handle_code,
											:quantity => 1
										)
				end										
			end
		end
	end		
	handle_asynchronously :asset_activity_summary_fact					

	def asset_location_network_in_out_report
#		first_date = @date.end_of_day
#		last_date = first_date - (86400 * 365)

		print @date.beginning_of_day.to_s + " <-- Start of Day \n"
		print @date.end_of_day.to_s + " <-- End of Day \n"
		print @date.to_s + " <-- Report Date \n\n"
		
		a = []
		AssetActivityFact.all.map {|x| [x.prev_location_network.description, x.location_network.description]}.each do |b|			
			a.push(b)
		end
		Entity.all.each do |entity|
			AssetLocationNetworkInOutSummaryFact.between(fact_time: @date.beginning_of_day..@date.end_of_day).where(:report_entity => entity).delete

			gatherer = Gatherer.new(entity)			
			location_network, product, asset_entity = gatherer.asset_activity_fact_criteria
			
			# Get Asset Activity Facts for given day & Group By location_network FOR IN BOUD
			asset_activity_facts = AssetActivityFact.between(fact_time: @date.beginning_of_day..@date.end_of_day).any_of(location_network, product, asset_entity ).desc(:fact_time)
			asset_activity_facts.group_by { |asset_activity_fact| asset_activity_fact.location_network_id }
				.each do |asset_activity_fact_by_location_network|
					
					# all asset activity for X location_network
					asset_activity_fact_by_location_network[1].each do |x|
						 if x.prev_location_network != x.location_network
						 	
						 	# MOVEMENT FACT INBOUND FACT
							asset_location_network_in_out_summary_fact = AssetLocationNetworkInOutSummaryFact.where(	
														:report_entity => entity,												
														:location_network => x.location_network,
														:product => x.product,
														:asset_type => x.asset_type,
													).between(fact_time: @date.beginning_of_day..@date.end_of_day).first

							if !asset_location_network_in_out_summary_fact.nil?									
								case x.asset_status.to_i
								when 0 # Empty

									asset_location_network_in_out_summary_fact.in_empty_quantity = asset_location_network_in_out_summary_fact.in_empty_quantity + 1
								when 1 # Full
									asset_location_network_in_out_summary_fact.in_full_quantity = asset_location_network_in_out_summary_fact.in_full_quantity + 1

								when 2 # Market
									asset_location_network_in_out_summary_fact.in_market_quantity = asset_location_network_in_out_summary_fact.in_market_quantity + 1

								end													
								asset_location_network_in_out_summary_fact.save!								
							else

								asset_location_network_in_out_summary_fact = AssetLocationNetworkInOutSummaryFact.new(	
																					:report_entity => entity,
																					:fact_time => @date,
																					:location_network => x.location_network,
																					:product => x.product,
																					:asset_type => x.asset_type,

																					:in_full_quantity => 0,
																					:in_empty_quantity => 0,
																					:in_market_quantity => 0,

																					:out_full_quantity => 0,
																					:out_empty_quantity => 0,
																					:out_market_quantity => 0
																			)
								case x.asset_status.to_i
								when 0 # Empty
									asset_location_network_in_out_summary_fact.in_empty_quantity = asset_location_network_in_out_summary_fact.in_empty_quantity + 1
								when 1 # Full
									asset_location_network_in_out_summary_fact.in_full_quantity = asset_location_network_in_out_summary_fact.in_full_quantity + 1
								when 2 # Market
									asset_location_network_in_out_summary_fact.in_market_quantity = asset_location_network_in_out_summary_fact.in_market_quantity + 1
								end													
								asset_location_network_in_out_summary_fact.save!																

							end											 	
						 end
					end
				end


			# Get Asset Activity Facts for given day & Group By location_network FOR OUT BOUND
			asset_activity_facts = AssetActivityFact.between(fact_time: @date.beginning_of_day..@date.end_of_day).any_of({:prev_location_network.in => gatherer.get_networks}, product, asset_entity ).desc(:fact_time)
			asset_activity_facts.group_by { |asset_activity_fact| asset_activity_fact.location_network_id }
			.each do |asset_activity_fact_by_location_network|
				
				# all asset activity for X location_network
				asset_activity_fact_by_location_network[1].each do |x|
					 if x.prev_location_network != x.location_network && !x.prev_location_network.nil?
					 	
					 	# MOVEMENT FACT INBOUND FACT
						asset_location_network_in_out_summary_fact = AssetLocationNetworkInOutSummaryFact.where(	
													:report_entity => entity,												
													:location_network => x.prev_location_network,
													:product => x.product,
													:asset_type => x.asset_type,
												).between(fact_time: @date.beginning_of_day..@date.end_of_day).first

						if !asset_location_network_in_out_summary_fact.nil?

							case x.asset_status.to_i
							when 0 # Empty
								asset_location_network_in_out_summary_fact.out_empty_quantity = asset_location_network_in_out_summary_fact.out_empty_quantity + 1
							when 1 # Full
								asset_location_network_in_out_summary_fact.out_full_quantity = asset_location_network_in_out_summary_fact.out_full_quantity + 1
							when 2 # Market
								asset_location_network_in_out_summary_fact.out_market_quantity = asset_location_network_in_out_summary_fact.out_market_quantity + 1
							end													
							asset_location_network_in_out_summary_fact.save!
						else

							asset_location_network_in_out_summary_fact = AssetLocationNetworkInOutSummaryFact.new(	
													:report_entity => entity,
													:fact_time => @date,
													:location_network => x.prev_location_network,
													:product => x.product,
													:asset_type => x.asset_type,
													:in_full_quantity => 0,
													:in_empty_quantity => 0,
													:in_market_quantity => 0,
													:out_full_quantity => 0,
													:out_empty_quantity => 0,
													:out_market_quantity => 0
												)
							case x.asset_status.to_i
							when 0 # Empty
								asset_location_network_in_out_summary_fact.out_empty_quantity = asset_location_network_in_out_summary_fact.out_empty_quantity + 1
							when 1 # Full
								asset_location_network_in_out_summary_fact.out_full_quantity = asset_location_network_in_out_summary_fact.out_full_quantity + 1
							when 2 # Market
								asset_location_network_in_out_summary_fact.out_market_quantity = asset_location_network_in_out_summary_fact.out_market_quantity + 1
							end													
							asset_location_network_in_out_summary_fact.save!							
						end											 	
					 end
				end
			end					
		end			
	end
	handle_asynchronously :asset_location_network_in_out_report
end