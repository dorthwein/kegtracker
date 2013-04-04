class BuildReport
	attr_accessor :date	
	def initialize(report_date = Time.now)
		@date = report_date #.beginning_of_day
	end

	def network_facts		
		Entity.all.each do |entity|				
#			print entity.description.to_s
#			print "\n ------------------------------------------------------ \n"

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
							if !d[0].nil?
								q[d[0]] = d[1].length
							end
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

#						print "Asset Summary Fact Created/Updated \n"
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
				#		print "Asset Activity Summary Fact Created/Updated \n"
					end
				end
			end	

	# Full Cycle Times					
			start = @date.beginning_of_day - (86400 * 90)

	# Step 1: Grab visible AssetCycleFact Networks
			print  "\n" + entity.description + "\n"
			by_network = entity.visible_asset_cycle_facts.where(cycle_complete: 1, cycle_quality: 1).gte(end_time: start ).map{|x| x.cycle_networks}.flatten.uniq
		 	by_network.each do |n|
		 		nd = Network.find(n)
		 		print nd.description + "\n"
		 	end
	# Step 2: For each network, get impacted facts
			by_network.each do |y|			
				asset_cycle_facts = entity.visible_asset_cycle_facts.gte(end_time: start).where(
					cycle_complete: 1, 
					cycle_quality: 1,
				)
#				.any_of(						
#					{:start_network_id.in => by_network},
#					{:fill_network_id.in => by_network},
#					{:delivery_network_id.in => by_network}
#				)


		# Step 3: Group by Product
				by_product = asset_cycle_facts.group_by{|x| x.product}
				by_product.each do |z|							
						
		# Step 4: Group by Asset Type
					by_asset_type = z[1].group_by{|x| x.asset_type}
					by_asset_type.each do |b|											


						t = []						
		# Step 5: Build Fact Set
						b[1].each do |c|														  
							t.push(c.completed_cycle_length)
						end

					# Process Fact Set
						avg = t.inject{ |sum, el| sum + el }.to_f / t.size
						minmax = []

						avg = (avg / 86400).ceil
						minmax[0] = (t.min.to_f / 86400).ceil
						minmax[1] = (t.max.to_f / 86400).ceil
							
#						print entity.description.to_s + ' -- ' + Network.find(y).description.to_s + ' -- ' + z[0].description.to_s + ' -- ' + b[0].description.to_s
#						print "\n"
#						print 'Min:' + minmax[0].to_s + ' Avg: ' + avg.to_s + ' Max:' + minmax[1].to_s + ' Count:' + b[1].length.to_i.to_s
#						print "\n"
#						print "\n"

						network_fact = NetworkFact.between(fact_time: @date.beginning_of_day..@date.end_of_day)
							.where(	:report_entity => entity,
									:location_network_id => y.to_s,
									:product => z[0],
									:asset_type => b[0],
							).first_or_create!

						if network_fact.update_attributes(
							:life_cycle_avg_time => avg.to_i,
							:life_cycle_min_time => minmax[0].to_i,
							:life_cycle_max_time => minmax[1].to_i,
							:life_cycle_completed_cycles => t.length.to_i,
							:fact_time => @date
						)
						else 

							print 'Save Failing'
						end
					end
				end
			end	
		end			
	end
 	def test_build
 		Entity.all.each do |entity|

		end
 	end
 end
