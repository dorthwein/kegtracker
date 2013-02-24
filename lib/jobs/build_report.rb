class BuildReport
	attr_accessor :date	
	def initialize(report_date = Time.now)
		@date = report_date #.beginning_of_day
	end

	def network_facts		
		Entity.all.each do |entity|				
			print entity.description.to_s
			print "\n ------------------------------------------------------ \n"

		# Asset Summary Report
			asset_activity_facts = entity.visible_asset_activity_facts.lte(fact_time: @date).desc(:fact_time)			
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

						network_fact = NetworkFact.between(fact_time: @date.beginning_of_day..@date.end_of_day)
							.where(	:report_entity => entity,
									:location_network => y[0],
									:product => z[0],
									:asset_type => b[0],																		
							).first_or_create!

						network_fact.update_attributes(
							:empty_quantity => q[0],	
							:full_quantity => q[1],
							:market_quantity => q[2],
							:fact_time => @date,
						)

						print "Asset Summary Fact Created/Updated \n"
					end
				end
			end


		# Asset Activity Summary
			asset_activity_facts = entity.visible_asset_activity_facts.between(fact_time: @date.beginning_of_day..@date.end_of_day).desc(:fact_time)
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

						network_fact = NetworkFact.between(fact_time: @date.beginning_of_day..@date.end_of_day)
							.where(	:report_entity => entity,
									:location_network => y[0],
									:product => z[0],
									:asset_type => b[0],
							).first_or_create!

						network_fact.update_attributes(
							:fill_quantity => q[4],	
							:delivery_quantity => q[1],	
							:pickup_quantity => q[2],
							:move_quantity => q[5],
							:fact_time => @date
						)
						print "Asset Activity Summary Fact Created/Updated \n"
					end
				end
			end	

		# Full Cycle Times
			# Assets that have had activity in the past year
			first_date = @date.beginning_of_day - (86400 * 365)
			last_date = @date.end_of_day

			# Distribution Channels			
			asset_activity_facts = entity.visible_asset_activity_facts.between(fact_time: first_date..last_date).gt(completed_cycle_time: 0).excludes(:fill_asset_activity_fact => nil).desc(:fact_time)
			by_network = asset_activity_facts.group_by{|x| x.location_network}
			by_network.each do |y|

				by_product = y[1].group_by{|x| x.product}
				by_product.each do |z|							

					by_asset_type = z[1].group_by{|x| x.asset_type}
					by_asset_type.each do |b|											
						
						t = []
						by_fill = b[1].group_by{|x| x.fill_asset_activity_fact}
						# Build Fact Set
						by_fill.each do |c|							
							# print c[0].class.to_s
							t.push(c[0].completed_cycle_length)
						end
						
						# Process Fact Set
						avg = t.inject{ |sum, el| sum + el }.to_f / t.size
						minmax = []

						avg = (avg / 86400).ceil
						minmax[0] = (t.min.to_f / 86400).ceil
						minmax[1] = (t.max.to_f / 86400).ceil
							
						print entity.description.to_s + ' -- ' + y[0].description.to_s + ' -- ' + z[0].description.to_s + ' -- ' + b[0].description.to_s						
						print "\n"
						print 'Min:' + minmax[0].to_s + ' Avg: ' + avg.to_s + ' Max:' + minmax[1].to_s + ' Count:' + b[1].length.to_i.to_s
						print "\n"
						print "\n"

						network_fact = NetworkFact.between(fact_time: @date.beginning_of_day..@date.end_of_day)
							.where(	:report_entity => entity,
									:location_network => y[0],
									:product => z[0],
									:asset_type => b[0],
							).first_or_create!

						network_fact.update_attributes(
							:life_cycle_avg_time => avg.to_i,
							:life_cycle_min_time => minmax[0].to_i,
							:life_cycle_max_time => minmax[1].to_i,
							:life_cycle_completed_cycles => b[1].length.to_i,
							:fact_time => @date
						)
						print "Cycle Fact Created/Updated \n"						
					end
				end
			end		
=begin
		# Full Cycle Times
			first_date = @date.beginning_of_day - (86400 * 7)
			last_date = @date.end_of_day
			
			asset_activity_facts = entity.visible_asset_activity_facts.between(fact_time: first_date..last_date).gt(completed_cycle_time: 0).desc(:fact_time)
#			print asset_activity_facts.to_json
#			print "\n"
#			print "\n"
#			asset_activity_facts = entity.visible_fill_activity_facts.between(fact_time: first_date..last_date)
			t = []

			asset_activity_facts.each do |a|
				if !a.nil?
					x = { 
						:fill_asset_activity_fact => a.fill_asset_activity_fact,
						:cycle_time => a.completed_cycle_time,
						:asset_type => a.asset_type,
						:product => a.product,
						:location_network => a.location_network,
					}
					t.push(x)
				end
			end
			print t.length
			t = t.uniq

			print "\n"
			print t.length
			print "\n"
			print "\n"
			by_network = t.group_by{|x| x[:location_network]}
			by_network.each do |y|

				by_product = y[1].group_by{|x| x[:product]}
				by_product.each do |z|							

					by_asset_type = z[1].group_by{|x| x[:asset_type]}
					by_asset_type.each do |b|											
							
						t = []						
						b[1].each do |c|							
							t.push(c[:cycle_time])
						end			
						avg = t.inject{ |sum, el| sum + el }.to_f / t.size						
						minmax = []

						avg = (avg / 86400).ceil
						minmax[0] = (t.min.to_f / 86400).ceil
						minmax[1] = (t.max.to_f / 86400).ceil
						
						print entity.description.to_s + ' -- ' + y[0].description.to_s + ' -- ' + z[0].description.to_s + ' -- ' + b[0].description.to_s						
						print "\n"
						print 'Min:' + minmax[0].to_s + ' Avg: ' + avg.to_s + ' Max:' + minmax[1].to_s + ' Count:' + b[1].length.to_i.to_s
						print "\n"
						print "\n"

						network_fact = NetworkFact.between(fact_time: @date.beginning_of_day..@date.end_of_day)
							.where(	:report_entity => entity,
									:location_network => y[0],
									:product => z[0],
									:asset_type => b[0],
							).first_or_create!

						network_fact.update_attributes(
							:life_cycle_avg_time => avg.to_i,
							:life_cycle_min_time => minmax[0].to_i,
							:life_cycle_max_time => minmax[1].to_i,
							:life_cycle_completed_cycles => b[1].length.to_i,
							:fact_time => @date
						)
						print "Cycle Fact Created/Updated \n"

					end
				end
			end						
=end			
		end			
	end
# **************************************
# Asset Summary Report Build
# **************************************
	def asset_summary_fact options = {}		
		options[:date] = @date
		Entity.all.each do |entity|			
			options[:date].nil? ? options[:date] = Time.new().end_of_day : options[:date].end_of_day

		
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
#	handle_asynchronously :asset_summary_fact					

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
#	handle_asynchronously :asset_activity_summary_fact					

	def asset_fill_to_fill_cycle_fact_by_fill_network
		first_date = @date.end_of_day - (86400 * 90)
		last_date = @date.end_of_day

		Entity.all.each do |entity|		
			AssetFillToFillCycleFactByFillNetwork.between(fact_time: @date.beginning_of_day..@date.end_of_day).where(:report_entity => entity).delete						

			# Basis
			asset_activity_facts = entity.visible_fill_activity_facts.between(fact_time: first_date..last_date)									
			t = []
			by_asset = asset_activity_facts.group_by{|x| x.asset}						
			by_asset.each do |b|					
				i = 0
				b[1].each do |c|
					i = i + 1						
					if !b[1][i].nil?
						cycle_time = c.fact_time - b[1][i].fact_time
						x = { 	
								:cycle_time => cycle_time,
								:asset_type_id => c.asset_type_id,
								:product_id => c.product_id,
								:fill_network_id => c.fill_network_id,
							}
						t.push(x)
					end
				end
			end

			by_network = t.group_by{|x| x[:fill_network_id]}
			by_network.each do |y|

				by_product = y[1].group_by{|x| x[:product_id]}
				by_product.each do |z|							

					by_asset_type = z[1].group_by{|x| x[:asset_type_id]}
					by_asset_type.each do |g|											
							
						t = []						
						g[1].each do |c|							
							t.push(c[:cycle_time])
						end			
						avg = t.inject{ |sum, el| sum + el }.to_f / t.size						
						minmax = []

						avg = (avg / 86400).ceil
						minmax[0] = (t.min / 86400).ceil
						minmax[1] = (t.max / 86400).ceil
						
						AssetFillToFillCycleFactByFillNetwork.create(
							:report_entity => entity,
							:fact_time => @date,
							:fill_network_id => y[0],
							:asset_type_id => g[0],
							:product_id => z[0],
							:avg_time => avg.to_i,
							:min_time => minmax[0].to_i,
							:max_time => minmax[1].to_i,
							:completed_cycles => g[1].length.to_i
						)	
					end
				end
			end			
		end		
	end

	def asset_fill_to_fill_cycle_fact_by_delivery_network
		first_date = @date.end_of_day - (86400 * 90)
		last_date = @date.end_of_day

		Entity.all.each do |entity|					
			AssetFillToFillCycleFactByDeliveryNetwork.between(fact_time: @date.beginning_of_day..@date.end_of_day).where(:report_entity => entity).delete
			asset_activity_facts = entity.visible_fill_activity_facts.between(fact_time: first_date..last_date)
			t = []
			by_asset = asset_activity_facts.group_by{|x| x.asset}						
			by_asset.each do |b|					
				i = 0
				b[1].each do |c|
					i = i + 1						
					if !b[1][i].nil?
						cycle_time = c.fact_time - b[1][i].fact_time
						x = { 	
								:cycle_time => cycle_time,
								:asset_type_id => c.asset_type_id,
								:product_id => c.product_id,
								:delivery_network_id => c.delivery_network_id,
							}
						t.push(x)
					end
				end
			end

			by_network = t.group_by{|x| x[:delivery_network_id]}
			by_network.each do |y|

				by_product = y[1].group_by{|x| x[:product_id]}
				by_product.each do |z|							

					by_asset_type = z[1].group_by{|x| x[:asset_type_id]}
					by_asset_type.each do |g|											
							
						t = []
						g[1].each do |c|							
							t.push(c[:cycle_time])
						end			
						avg = t.inject{ |sum, el| sum + el }.to_f / t.size
						minmax = []						

						avg = (avg / 86400).ceil
						minmax[0] = (t.min / 86400).ceil
						minmax[1] = (t.max / 86400).ceil

						fact = AssetFillToFillCycleFactByDeliveryNetwork.create(
							:report_entity => entity,
							:fact_time => @date,
							:delivery_network_id => y[0],
							:asset_type_id => g[0],
							:product_id => z[0],
							:avg_time => avg.to_i,
							:min_time => minmax[0].to_i,
							:max_time => minmax[1].to_i,
							:completed_cycles => g[1].length.to_i

						)		
						print fact.fact_time
						print "\n"							

					end
				end
			end			
		end		
	end
end
