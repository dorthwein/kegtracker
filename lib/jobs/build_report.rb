class BuildReport
	attr_accessor :date	
	def initialize(report_date)
		@date = report_date.beginning_of_day + 10
	end

	def daily_facts
#		belongs_to :location
#		belongs_to :asset_entity, :class_name => 'Entity' 	# Asset Owner
#		belongs_to :product
#		belongs_to :asset_type, :class_name => 'AssetType' 

#		field :location_network_type, type: Integer
#		field :asset_status, type: Integer
#		field :fact_time, type: Time

# Prep Stage

#		locations = asset_activity_facts.group_by{|x| x.location}.map{|x| x[0]._id}
#		asset_entities = asset_activity_facts.group_by{|x| x.entity}.map{|x| x[0]._id}
#		products = asset_activity_facts.group_by{|x| x.product}.map{|x| x[0]._id}
#		asset_types = asset_activity_facts.group_by{|x| x.asset_type}.map{|x| x[0]._id}		
#		asset_status = asset_activity_facts.group_by{|x| x.asset_status}.map{|x| x[0]}		
		
#:location_id => a,
#:asset_entity => b,
#:product_id => c,
#:asset_type_id => d,
#:asset_status => f,

		asset_activity_facts = AssetActivityFact.any_of(
			{ :next_asset_activity_fact_time.gt => @date },
			{ :next_asset_activity_fact_time => nil, :fact_time.lt => @date }
		).desc(:fact_time)


		# ****************		
		# Asset Counts
		# ****************
		total_ce = BigDecimal.new(0)
		total_qty = 0
		by_location = asset_activity_facts.group_by{|x| x.location_id}		
		by_location.each do |a|
			
			by_asset_entity = a[1].group_by{|x| x.entity_id}
			by_asset_entity.each do |b|

				by_product = b[1].group_by{|x| x.product_id}
				by_product.each do |c|

					by_asset_type = c[1].group_by{|x| x.asset_type_id}
					by_asset_type.each do |d|
						
						by_asset_status = d[1].group_by{|x| x.asset_status}
						by_asset_status.each do |f|
						##############################
							# Qty Assets								
							qty = f[1].count
							total_qty = total_qty + qty
							
							# Case Equivalent								
							unless f[1].nil? || d[0].nil?
								asset_type = AssetType.find(d[0])
								ce = asset_type.measurement_unit_qty * f[1].count
								total_ce = total_ce + ce
								#print f[1].count.to_s + "\n"
							else
								ce = 0
							end

							# Find Fact
							unless f[1].count == 0 || f[1].nil?
								daily_fact = DailyFact.between(fact_time: @date.beginning_of_day..@date.end_of_day).find_or_create_by(
									:location_id => a[0],
									:asset_entity => b[0],
									:product_id => c[0],
									:asset_type_id => d[0],
									:asset_status => f[0],
								)
								daily_fact.update_attributes(
									:quantity => qty,
									:fact_time => @date,
									:case_equivalent => ce,
								)
							end
						##############################
						end					
					end
				end
			end
		end

		one_year_back = @date.beginning_of_day - (86400 * 365)
		# Go Back update totals
		one_year_back_asset_activity_facts = AssetActivityFact.between(fact_time: one_year_back..@date.end_of_day)
		
		# ********************************		
		# Time at Location
		# ********************************
		total_ce = BigDecimal.new(0)
		total_qty = 0
		by_location = one_year_back_asset_activity_facts.group_by{|x| x.location_id}		
		by_location.each do |a|
			
			by_asset_entity = a[1].group_by{|x| x.entity_id}
			by_asset_entity.each do |b|

				by_product = b[1].group_by{|x| x.product_id}
				by_product.each do |c|

					by_asset_type = c[1].group_by{|x| x.asset_type_id}
					by_asset_type.each do |d|
						
						by_asset_status = d[1].group_by{|x| x.asset_status}
						by_asset_status.each do |f|

							# Avg Time @ Location
							days_at_location_sample = f[1].map{|x| x.days_at_location } 


							days_at_location_sample.delete_if {|x| x == nil }
							days_at_location_sample.delete_if {|x| x == 'null'}
							days_at_location_sample.delete_if {|x| x == 0}

							

							
							unless days_at_location_sample.size == 0
							# Avg
								days_at_location_avg = days_at_location_sample.inject(:+).to_f / days_at_location_sample.size
								
							# Find Fact								
								daily_fact = DailyFact.between(fact_time: @date.beginning_of_day..@date.end_of_day).find_or_create_by(
									:location_id => a[0],
									:asset_entity => b[0],
									:product_id => c[0],
									:asset_type_id => d[0],
									:asset_status => f[0],
								)

								daily_fact.update_attributes(
									:fact_time => @date,
									:days_at_location_sample_size => days_at_location_sample.size,
									:days_at_location_avg => days_at_location_avg,
								)
							end
						##############################
						end					
					end
				end
			end
		end

#		print @date.to_s + "\n"
#		print asset_activity_facts.count.to_s + '  --  ' + Asset.all.count.to_s + ' -- ' + asset_activity_facts.group_by{|x| x.asset }.map{|x| x[0]._id }.count.to_s + "\n \n"
#		print asset_activity_facts.first.to_json + " \n \n \n " + asset_activity_facts.last.to_json
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
		# Uses cycles that ended in last 30 days
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

 	def process_billing

 		Entity.all.each do |entity| 			
 		# Get Current Invoice
 			current_billing_month = @date.month
 			current_billing_year = @date.year
			current_invoice = BreweryAppsInvoice.find_or_create_by(bill_to_entity_id: entity._id, billing_period_month: current_billing_month, billing_period_year: current_billing_year)


		# BILLING FACTS		
			billing_fact = BillingFact.between(fact_time: @date.beginning_of_day..@date.end_of_day)
				.where(	:bill_to_entity_id => entity._id,
			).first_or_create!

			# Double check make sure not already paid
			if billing_fact.paid.to_i == 0
				# General Fact Update
				billing_fact.update_attributes!(
 					:fact_time => @date,
 					:brewery_apps_invoice_id => current_invoice._id
 				)

 				# Get Assets the entity owns
	 			assets = entity.assets.where(:asset_type.ne => nil)
	 			total_ces = BigDecimal.new(0)
				rate = BigDecimal.new(entity.kt_rate)
				# KegTracker Pricing Calculation
				if entity.keg_tracker == 1
		 			
		 			# For each asset type, get total CEs for assets of that type
		 			assets.group_by{ |x| x.asset_type_id }.each do |x|	 			 				
		 				asset_type = AssetType.find(x[0])		 						 		
		 				total_ces = total_ces +  (BigDecimal.new(x[1].length.to_i) * asset_type.measurement_unit_qty )
		 				
		 			end
				end
				
				cost = rate * total_ces
				billing_fact.update_attributes!(
 					:kt_assets => assets.map{|x| x._id},
 					:kt_ce_days => total_ces,
 					:kt_rate => rate,
 					:kt_charge => cost,
				)
			end


		# KEGTRACKER LINE ITEMS	
			subscription_code = 1
			keg_tracker_billable_units = BigDecimal.new(0)
			keg_tracker_rate = entity.kt_rate
			keg_tracker_total = BigDecimal.new(0)

			current_invoice.billing_facts.where(:paid => 0).each do |x|
				keg_tracker_billable_units = keg_tracker_billable_units + x.kt_ce_days
				keg_tracker_total = keg_tracker_total + x.kt_charge
			end
			keg_tracker_total = keg_tracker_total.round(2)

			# Find or Create Line Item
			if keg_tracker_total > 0
				keg_tracker_line_item = BreweryAppsInvoiceLineItem.find_or_create_by(
					brewery_apps_invoice_id: current_invoice._id,
					subscription_code: subscription_code,
					entity_id: entity._id
				)

				# Update Line Item
				keg_tracker_line_item.update_attributes!(
					:billable_units => keg_tracker_billable_units,
					:billing_rate => keg_tracker_rate,
					:total => keg_tracker_total
				)
			end



		# TOTAL INVOICE
			invoice_total = BigDecimal.new(0)
			current_invoice.brewery_apps_invoice_line_items.each do |x|
				invoice_total = invoice_total + x.total
			end
			invoice_total = invoice_total.round(2)
			# Fill in current_invoice details
			current_invoice.update_attributes!(
				:status => 1,
				:billing_period_start => (@date.beginning_of_month).beginning_of_day,
				:billing_period_end => (@date.end_of_month - 86400).end_of_day,
				:total => invoice_total,
			)

		# CLOSE PREVIOUS MONTH INVOICES
# { "token":"5HOk9MyW2OFdyHl1mRiozbAEG0Y","created_at":"2013-04-16T14:45:30Z","updated_at":"2013-04-16T21:06:33Z","email":null,"data":null,"last_four_digits":"1111","card_type":"visa","first_name":"Daniel","last_name":"Orthwein","month":12,"year":2013,"address1":"2730 S. Lindbergh","address2":null,"city":"St. Louis","state":"MO","zip":"63131","country":null,"phone_number":null,"payment_method_type":"credit_card","errors":[],"verification_value":null,"number":"XXXX-XXXX-XXXX-1111","has_been_validated":true,"http_code":200}
		end
		# Get previous month non-paid invoices and set to pending payment
		BreweryAppsInvoice.where(:billing_period_end.lt => @date.beginning_of_month, :status.ne => 3).each do |x|
			x.update_attributes(:status => 2)
		end
 	end

 	def charge_credit_card
 		Entity.all.each do |entity| 
 			# Get pending payment invoices
 			if entity.billing_status == 1 || entity.billing_status == 2
	 			BreweryAppsInvoice.where(	
	 				status: 2, 
	 				bill_to_entity_id: entity._id,
	 				:billing_period_end.lt => @date.beginning_of_month
	 			).each do |x|	 				
	 				if x.total > 0
	 					charge_amount = (x.total * 100).to_i

						token = entity.payment_token
						
						payment_method = SpreedlyCore::PaymentMethod.find(token)
						purchase_transaction = payment_method.purchase(charge_amount, {:gateway_token => ENV['SPREEDLYCORE_API_GATEWAY_TOKEN']})
						if purchase_transaction.succeeded?
							x.update_attributes(
								status: 3,
								payment_token: purchase_transaction.token,
								payment_card_ending: payment_method.last_four_digits,
								payment_date: @date
							)							
						else
							entity.update_attributes(
								:billing_status => 2
							)
						end
					end 			
	 			end
	 		end
 		end		
 	end
 end





