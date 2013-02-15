class BuildReport
	attr_accessor :date	
	def initialize(report_date = Time.now)
		@date = report_date #.beginning_of_day
	end

# **************************************
# Asset Summary Report Build
# **************************************
	def asset_summary_fact options = {}		
		options[:date] = @date
		Entity.all.each do |entity|
			
			options[:date].nil? ? options[:date] = Time.new().end_of_day : options[:date].end_of_day

			# Clear existing day reports
			AssetSummaryFact.between(fact_time: options[:date].beginning_of_day..options[:date].end_of_day).where(:report_entity => entity).delete_all
			asset_activity_facts = entity.visible_asset_activity_facts.lte(fact_time: options[:date]).desc(:fact_time)
			
			assets = asset_activity_facts.group_by{|x| x.asset }.map{|x| x[1].first }
			by_network = assets.group_by{|x| x.location_network}
			by_network.each do |y|

				by_product = y[1].group_by{|x| x.product}	
				by_product.each do |z|							

					by_asset_type = z[1].group_by{|a| a.asset_type}
					by_asset_type.each do |b|
						q = [0,0,0]

						by_asset_status = b[1].group_by{|c| c.asset_status }					
						by_asset_status.each do |d|
							q[d[0]] = d[1].length
						end

						asset_summary_fact = AssetSummaryFact.create(	
													:report_entity => entity,
													:fact_time => options[:date],
													:location_network => y[0],
													:product => z[0],
													:asset_type => b[0],
													:empty_quantity => q[0],	
													:full_quantity => q[1],
													:market_quantity => q[2]
												)			
						print "Asset Summary Fact Created \n"
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
			asset_activity_facts = entity.visible_asset_activity_facts.between(fact_time: first_date..last_date).desc(:fact_time)
			assets = asset_activity_facts.group_by{|x| x.asset }.map{|x| x[1].first }
			by_network = assets.group_by{|x| x.location_network}
			by_network.each do |y|

				by_product = y[1].group_by{|x| x.product}	
				by_product.each do |z|							

					by_asset_type = z[1].group_by{|a| a.asset_type}
					by_asset_type.each do |b|
						q = [0,0,0,0,0,0]

						by_handle_code = b[1].group_by{|c| c.handle_code }					
						by_handle_code.each do |d|
							q[d[0]] = d[1].length
						end

						asset_summary_fact = AssetActivitySummaryFact.create(	
													:report_entity => entity,
													:fact_time => @date,
													:location_network => y[0],
													:product => z[0],
													:asset_type => b[0],
													:fill_quantity => q[4],	
													:delivery_quantity => q[1],	
													:pickup_quantity => q[2],
													:move_quantity => q[5]
												)			
						print "Asset Activity Summary Fact Created \n"
					end
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
#		AssetActivityFact.all.map {|x| [x.prev_location_network.description, x.location_network.description]}.each do |b|
#			a.push(b)
#		end
	
		Entity.all.each do |entity|
=begin
			AssetLocationNetworkInOutSummaryFact.between(fact_time: first_date..last_date).where(:report_entity => entity).delete
			
#			gatherer = Gatherer.new entity
#			location_network, product, asset_entity = gatherer.asset_activity_fact_criteria
			asset_activity_facts = entity.visible_asset_activity_facts.lte(fact_time: options[:date]).desc(:fact_time)			
			assets = asset_activity_facts.group_by{|x| x.asset }.map{|x| x[1].first }
			by_network = assets.group_by{|x| x.location_network}
			by_network.each do |y|

				by_product = y[1].group_by{|x| x.product}	
				by_product.each do |z|							

					by_asset_type = z[1].group_by{|a| a.asset_type}
					by_asset_type.each do |b|
						q = [0,0,0,0,0,0]

						by_handle_code = b[1].group_by{|c| c.handle_code }					
						by_handle_code.each do |d|
							q[d[0]] = d[1].length
						end

						asset_summary_fact = AssetLocationNetworkInOutSummaryFact.create(	
													:report_entity => entity,
													:fact_time => @date,
													:location_network => y[0],
													:product => z[0],
													:asset_type => b[0],
													:fill_quantity => q[4],	
													:delivery_quantity => q[1],	
													:pickup_quantity => q[2],
													:move_quantity => q[5]
												)			
						print "Asset Activity Summary Fact Created \n"
					end
				end
			end	

=begin
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
=end							
		end			
	end
	handle_asynchronously :asset_location_network_in_out_report
end