class BuildReport
	attr_accessor :date	
	def initialize(report_date)
		@date = report_date.beginning_of_day + 43200
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
						print @date.to_s + " <--- \n"

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

	# Delivery Cycles - Brewer & Asset Owner Only
			start = @date.beginning_of_day - (86400 * 30)
			by_network = entity.visible_asset_cycle_facts.where(cycle_complete: 1, cycle_quality: 1).gte(end_time: start ).map{|x| x.delivery_network_id}.delete_if{|x| x == nil}.flatten.uniq
			by_network.each do |y|			
				asset_cycle_facts = entity.visible_asset_cycle_facts.gte(end_time: start).where(
					cycle_complete: 1, 
					cycle_quality: 1,
					delivery_network_id: y
				)
				by_product = asset_cycle_facts.group_by{|x| x.product}
				by_product.each do |z|														
					by_asset_type = z[1].group_by{|x| x.asset_type}
					by_asset_type.each do |b|
						t = []		
						b[1].each do |c|
							t.push(c.completed_cycle_length)
						end
						avg = t.inject{ |sum, el| sum + el }.to_f / t.size
						minmax = []

						avg = (avg / 86400).ceil
						minmax[0] = (t.min.to_f / 86400).ceil
						minmax[1] = (t.max.to_f / 86400).ceil
							
						network_fact = NetworkFact.between(fact_time: @date.beginning_of_day..@date.end_of_day)
							.where(	:report_entity_id => entity._id,
									:location_network_id => y,
									:product_id => z[0]._id,
									:asset_type_id => b[0]._id,
							).first_or_create!

						if network_fact.update_attributes(
							:delivery_life_cycle_avg_time => avg.to_i,
							:delivery_life_cycle_min_time => minmax[0].to_i,
							:delivery_life_cycle_max_time => minmax[1].to_i,
							:delivery_life_cycle_completed_cycles => t.length.to_i,
							:fact_time => @date
						)
						else 
							print 'Save Failing'
						end
					end
				end
			end	

	# Fill Cycles - Brewer & Asset Owner Only
			start = @date.beginning_of_day - (86400 * 30)
			by_network = entity.visible_asset_cycle_facts.where(cycle_complete: 1, cycle_quality: 1).gte(end_time: start ).map{|x| x.fill_network_id}.delete_if{|x| x == nil}.flatten.uniq
			by_network.each do |y|			
				asset_cycle_facts = entity.visible_asset_cycle_facts.gte(end_time: start).where(
					cycle_complete: 1, 
					cycle_quality: 1,
					fill_network_id: y
				)
				by_product = asset_cycle_facts.group_by{|x| x.product}
				by_product.each do |z|														
					by_asset_type = z[1].group_by{|x| x.asset_type}
					by_asset_type.each do |b|
						t = []		
						b[1].each do |c|
							t.push(c.completed_cycle_length)
						end
						avg = t.inject{ |sum, el| sum + el }.to_f / t.size
						minmax = []

						avg = (avg / 86400).ceil
						minmax[0] = (t.min.to_f / 86400).ceil
						minmax[1] = (t.max.to_f / 86400).ceil
							
						network_fact = NetworkFact.between(fact_time: @date.beginning_of_day..@date.end_of_day)
							.where(	:report_entity_id => entity._id,
									:location_network_id => y,
									:product_id => z[0]._id,
									:asset_type_id => b[0]._id,
							).first_or_create!

						if network_fact.update_attributes(
							:fill_life_cycle_avg_time => avg.to_i,
							:fill_life_cycle_min_time => minmax[0].to_i,
							:fill_life_cycle_max_time => minmax[1].to_i,
							:fill_life_cycle_completed_cycles => t.length.to_i,
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
