class ChartBuilder < ApplicationController
	def initialize user
		# Gatherer Params
		@entity = user.entity
		@user = user

		# Chart Params
		@chart_opacity = '.5'.to_f
	end
	def parse_filter filters
		filters.each_key do |key|
#			filters[key].map! { |x| x == "nil" ? nil : x }
		end
#		return filters
	end
	def assets_by_network fact_time_start = Time.new.beginning_of_day, fact_time_end = Time.new.end_of_day, filters = {}	
		# Report driven by Asset Summary facts

#		filters = parse_filter(filters)	

		series = Array.new
#		products = filters['product_id'] # || []
#		location_networks = filters['location_network_id'] # || []
#		asset_types = filters['asset_type_id'] # || []
#		asset_states = filters['asset_state_id'] # || []

		asset_summary_facts = AssetSummaryFact.where(:report_entity => @entity)
												.between(fact_time: fact_time_start..fact_time_end)
												.asc(:fact_time)
												
		series = []
		asset_summary_facts.group_by{|asset_summary_fact| asset_summary_fact.location_network_id}.each do |asset_summary_fact|		
			a = {:dataField => asset_summary_fact[1][0].location_network_id, :displayText => asset_summary_fact[1][0].location_network_description}
			series.push(a)
		end

		source_records = []
		current_day = fact_time_start.beginning_of_day
		while current_day.beginning_of_day < fact_time_end do
			
			record = {:date => current_day.beginning_of_day.strftime("%D")}

			asset_summary_facts.between(fact_time: current_day.beginning_of_day..current_day.end_of_day).group_by{|asset_summary_fact| asset_summary_fact.location_network_id}.each do |asset_summary_fact_by_location_network_id|
				days_quantity = 0
				asset_summary_fact_by_location_network_id[1].each do |asset_summary_fact|					
					days_quantity = days_quantity + asset_summary_fact.full_quantity
				end
				record.merge!({asset_summary_fact_by_location_network_id[0] => days_quantity  })
			end
			source_records.push(record)
			current_day = current_day + 86400				
		end

		chart_unit_interval = 5		

		chart = {
			:title => " Assets by Network",
			:showLegend => true,
			:width => '30%',
			:padding => {:left => 5, :top => 5, :right => 5, :bottom => 5},
			:source => source_records,
			:categoryAxis => {
				:dataField => 'date',						
				:textRotationAngle => 90,
#				:showTickMarks => true,
#						:tickMarksInterval => 1,
				:tickMarksColor => '#888888',
                :axisSize => 'auto',
				:alignEndPointsWithIntervals => true,				
				:unitInterval => 5,
#				:showGridLines => true,
#						:gridLinesInterval => 5,
#        		:showLegend => true,
        		:enableAnimations => true,						
				:gridLinesColor => '#888888',
#				:valuesOnTicks => true									
			},
			:colorScheme => 'scheme01',
			:seriesGroups => [
				{
					:alignEndPointsWithIntervals => true,
					:type => 'stackedsplinearea',
					:valueAxis => {
 #                       :minValue => 0,
#                        :maxValue => 200,
                        :unitInterval => 30,
						:displayValueAxis =>  true,
                        :description => '# Assets',
#						:formatSettings => { :decimalPlaces =>  0 },
#						:unitInterval => chart_unit_interval,
                        :tickMarksColor => '#888888',                        				
					},
					:series => series,					
				}
			]					
		}				
		return chart
	end

	def sku_by_network fact_time_start = Time.new.beginning_of_day, fact_time_end = Time.new.end_of_day, filters = {}
		# Report driven by Asset Summary facts
		filters = parse_filter(filters)

		series = Array.new
		products = filters['product_id']
		location_networks = filters['location_network_id']
		asset_types = filters['asset_type_id']
		asset_states = filters['asset_state_id']

		asset_summary_facts = AssetSummaryFact.where(:report_entity => @entity)
												.between(fact_time: fact_time_start..fact_time_end)
												.where(:product.in => products)
												.where(:location_network.in => location_networks)
												.where(:asset_type.in => asset_types)
												.where(:asset_state.in => asset_states)
												.asc(:fact_time)
												
		series = []

		# Asset Summary Facts
		sku_products = asset_summary_facts.group_by{|asset_summary_fact| asset_summary_fact.product_id }
		sku_asset_types = asset_summary_facts.group_by{|asset_summary_fact| asset_summary_fact.asset_type_id}

		sku_products.each do |sku_product|
			sku_asset_types.each do |sku_asset_type|
				a = asset_summary_facts.where(:product => sku_product[0], :asset_type => sku_asset_type[0]).first
				if !a.nil?
					b = {:dataField => a.product_id.to_s + '_' + a.asset_type_id.to_s + '_' + a.product_id.class.to_s , :displayText => a.product_description.to_s + ' - ' + a.asset_type_description.to_s }
					series.push(b)
				end
			end
		end







		source_records = []
		current_day = fact_time_start.beginning_of_day
		while current_day < fact_time_end do
			days_quantity = 0
			record = {:date => current_day.beginning_of_day.strftime("%D")}
			sku_products.each do |sku_product|
				sku_asset_types.each do |sku_asset_type|
					a = asset_summary_facts.between(fact_time: current_day.beginning_of_day..current_day.end_of_day).where(:product => sku_product[0], :asset_type => sku_asset_type[0])
					quantity = 0
					a.each do |asset_summary_fact|
						quantity = quantity + asset_summary_fact.quantity
					end
					if quantity > 0
						record.merge!({sku_product[0].to_s + '_' + sku_asset_type[0].to_s + '_' + sku_product[0].class.to_s => quantity})
					end
				end
			end
			source_records.push(record)
			current_day = current_day + 86400				
		end
		

		chart_unit_interval = 5		

		chart = {
			:title => " SKU Quantity",
			:showLegend => true,
			:width => '30%',
			:padding => {:left => 5, :top => 5, :right => 5, :bottom => 5},
			:source => source_records,
			:categoryAxis => {
				:dataField => 'date',						
				:textRotationAngle => 90,
#				:showTickMarks => true,
#						:tickMarksInterval => 1,
				:tickMarksColor => '#888888',
                :axisSize => 'auto',

				:unitInterval => 5,
#				:showGridLines => true,
#						:gridLinesInterval => 5,
#        		:showLegend => true,
        		:enableAnimations => true,						
				:gridLinesColor => '#888888',
				:alignEndPointsWithIntervals => true,				

#				:valuesOnTicks => true									
			},
			:colorScheme => 'scheme01',
			:seriesGroups => [
				{
					:alignEndPointsWithIntervals => true,
					:type => 'stackedsplinearea',
					:valueAxis => {
                        :minValue => 0,
                        :maxValue => 200,
                        :unitInterval => 30,
						:displayValueAxis =>  true,
                        :description => '# Assets',
#						:formatSettings => { :decimalPlaces =>  0 },
#						:unitInterval => chart_unit_interval,
                        :tickMarksColor => '#888888',                        				
					},
					:series => series,					
				}
			]					
		}				
		return chart
	end	

	def current_sku_quantities fact_time_start = Time.new.beginning_of_day, fact_time_end = Time.new.end_of_day, filters = {}
		filters = parse_filter(filters)

		series = Array.new
		products = filters['product_id']
		location_networks = filters['location_network_id']
		asset_types = filters['asset_type_id']
		asset_states = filters['asset_state_id']

		asset_summary_facts = AssetSummaryFact.where(:report_entity => @entity)
												.between(fact_time: fact_time_start..fact_time_end)
												.where(:product.in => products)
												.where(:location_network.in => location_networks)
												.where(:asset_type.in => asset_types)
												.where(:asset_state.in => asset_states)
												.asc(:fact_time)
												
		series = []
=begin
                    { Day: '', Running: 30, Swimming: 0, Cycling: 25 },
                    { Day: 'Tuesday', Running: 25, Swimming: 25, Cycling: 0 },
                    { Day: 'Wednesday', Running: 30, Swimming: 0, Cycling: 25 },
                    { Day: 'Thursday', Running: 35, Swimming: 25, Cycling: 45 },
                    { Day: 'Friday', Running: 0, Swimming: 20, Cycling: 25 },
                    { Day: 'Saturday', Running: 30, Swimming: 0, Cycling: 30 },
                    { Day: 'Sunday', Running: 60, Swimming: 45, Cycling: 0 }

                                    { dataField: 'Running', displayText: 'Running' },
                                    { dataField: 'Swimming', displayText: 'Swimming' },
                                    { dataField: 'Cycling', displayText: 'Cycling' }

=end
		# Asset Summary Facts
		sku_products = asset_summary_facts.group_by{|asset_summary_fact| asset_summary_fact.product_id }
		sku_asset_types = asset_summary_facts.group_by{|asset_summary_fact| asset_summary_fact.asset_type_id}

		sku_products.each do |sku_product|
			a = asset_summary_facts.where(:product => sku_product[0]).first
			if !a.nil?
				b = {:dataField => a.product_id.to_s + '_' + a.product_id.class.to_s, :displayText => a.product_description }
				series.push(b)
			end
		end		



		source_records = []
		days_quantity = 0
		
		unit_interval_quantity = 1
		sku_asset_types.each do |sku_asset_type|			
			record = {:asset_type => sku_asset_type[1][0].asset_type_description}		

			sku_products.each do |sku_product|			
				a = asset_summary_facts.between(fact_time: fact_time_start..fact_time_end).where(:product => sku_product[0], :asset_type => sku_asset_type[0])
				quantity = 0
				
				a.each do |asset_summary_fact|
					quantity = quantity + asset_summary_fact.quantity
				end
				record.merge!({sku_product[0].to_s + '_' + sku_product[0].class.to_s => quantity})

				if quantity > unit_interval_quantity
					unit_interval_quantity = quantity
				end
			end
			source_records.push(record)
		end						
		chart_unit_interval = (unit_interval_quantity/5).ceil

		chart = {
			:title => "Current ",
			:showLegend => true,
			:width => '30%',
			:padding => {:left => 5, :top => 5, :right => 5, :bottom => 5},
			:source => source_records,
			:categoryAxis => {
				:dataField => :asset_type,						                        
                :textRotationAngle => 90,
                
                #:formatFunction => "function (value) { return value.toString() }",
                :showTickMarks => true,
                :tickMarksStartInterval => 1,
                :tickMarksInterval => 1,
                :tickMarksColor => '#888888',

                :unitInterval => 1,
                :showGridLines => true,
                
                :gridLinesStartInterval => 1,
                :gridLinesInterval => 1,
                :gridLinesColor => '#888888',
                :axisSize => 'auto',

                :valuesOnTicks => false,
        		:enableAnimations => true,													
				:alignEndPointsWithIntervals => true,				
			},
			:colorScheme => 'scheme01',
			:seriesGroups => [
				{				
					:type => 'stackedcolumn',				
					:valueAxis => {
                        :displayValueAxis =>  true,
                        :description => 'Products',
						:formatSettings => { :decimalPlaces =>  0 },
						:unitInterval => chart_unit_interval,
                        :tickMarksColor => '#888888',
					},
					:series => series,
				}
			]					
		}		
		return chart

	end
=begin
	def asset_summary_quantity_current
		gatherer = Gatherer.new @entity
		# Gather Data Fields
		series = Array.new
		asset_summary_facts = gatherer.get_asset_summary_facts.between(fact_time: Time.new.beginning_of_day..Time.new.end_of_day)

		# !!! NEED TO INCLUDE SUMMING COMPONENT !!!

		series = [{:dataField => :quantity, :displayText => 'Quantity'}]
		source_records = Array.new
		source_records = source_records + asset_summary_facts.map {|asset_summary_fact| {:product => asset_summary_fact.product_description, :quantity => asset_summary_fact.quantity } }
		
		chart_unit_interval = 5		
		source_records.each do |source_record|
			if source_record[:quantity] > chart_unit_interval
				chart_unit_interval = source_record[:quantity]
			end
		end
		chart_unit_interval = (chart_unit_interval/5).ceil
		print chart_unit_interval.to_s + 'MARK ==> '

		chart = {
			:title => "Test Chart",
			:showLegend => true,
			:width => '30%',
			:padding => {:left => 5, :top => 5, :right => 5, :bottom => 5},
			:source => source_records,
			:categoryAxis => {
				:dataField => :product,						                        
                :textRotationAngle => 90,
                
                #:formatFunction => "function (value) { return value.toString() }",
                :showTickMarks => true,
                :tickMarksStartInterval => 1,
                :tickMarksInterval => 1,
                :tickMarksColor => '#888888',

                :unitInterval => 1,
                :showGridLines => true,
                
                :gridLinesStartInterval => 1,
                :gridLinesInterval => 1,
                :gridLinesColor => '#888888',
                :axisSize => 'auto',

                :valuesOnTicks => false,
        		:enableAnimations => true,													
				:alignEndPointsWithIntervals => true,				
			},
			:colorScheme => 'scheme01',
			:seriesGroups => [
				{				
					:type => 'column',				
					:valueAxis => {
                        :displayValueAxis =>  true,
                        :description => 'Products',
						:formatSettings => { :decimalPlaces =>  0 },
						:unitInterval => chart_unit_interval,
                        :tickMarksColor => '#888888',
					},
					:series => series,
				}
			]					
		}
		return chart		
	end
=begin
	def asset_summary_quantity_by_time		
		gatherer = Gatherer.new @entity
		# Gather Data Fields
		series = Array.new
		asset_summary_facts = gatherer.get_asset_summary_facts

		# !!! NEED TO INCLUDE SUMMING COMPONENT !!!
		

		asset_summary_facts.group_by{ |asset_summary_fact| asset_summary_fact.product_id }.each do |asset_summary_fact_by_product|
			print asset_summary_fact_by_product[0].nil?.to_s  + "<-- Nil? " + asset_summary_fact_by_product[0].to_s + "\n"
			if asset_summary_fact_by_product[0].nil?
				asset_summary_fact_by_product[0] = 'unknown'
				asset_summary_fact_by_product[1][0] = 'Unknown'
			end
			series.push({ :dataField => asset_summary_fact_by_product[0],  :opacity => @chart_opacity, :displayText => asset_summary_fact_by_product[1][0].product_description })
		end

		# Gather Data Sources
		chart_unit_interval = 5	

		source_records = Array.new
		asset_summary_facts.group_by{ |asset_summary_fact| asset_summary_fact.fact_time }.each do |asset_summary_fact_by_fact_time|
			record = { :date => asset_summary_fact_by_fact_time[0] }
			asset_summary_fact_by_fact_time[1].each do |asset_summary_facts_by_fact_time_detail|

				if asset_summary_facts_by_fact_time_detail.quantity > chart_unit_interval
					chart_unit_interval = asset_summary_facts_by_fact_time_detail.quantity
				end
				
				if asset_summary_fact_by_product[0].nil?
					product_id = 'unknown'
				else				
					product_id = asset_summary_facts_by_fact_time_detail.product_id
				end				
		
				record.merge!( { product_id => asset_summary_facts_by_fact_time_detail.quantity * 5 } )
			end
			source_records.push(record)
		end

		chart_unit_interval = (chart_unit_interval).ceil
		print source_records.to_json + "MARK \N \N"
		chart = {
			:title => "Test Chart",
			:showLegend => true,
			:width => '30%',
			:padding => {:left => 5, :top => 5, :right => 5, :bottom => 5},
			:source => source_records,
			:categoryAxis => {
				:dataField => 'date',						
				:textRotationAngle => 90,
				:showTickMarks => true,
#						:tickMarksInterval => 1,
				:tickMarksColor => '#888888',
#						:unitInterval => 5,
				:showGridLines => true,
#						:gridLinesInterval => 5,
        		:showLegend => true,
        		:enableAnimations => true,						
				:gridLinesColor => '#888888',
				:valuesOnTicks => true									
			},
			:colorScheme => 'scheme01',
			:seriesGroups => [
				{
					:alignEndPointsWithIntervals => true,
					:type => 'stackedsplinearea',
					:valueAxis => {                        	
						:displayValueAxis =>  true,
                        :description => 'Products',
						:formatSettings => { :decimalPlaces =>  0 },
						:unitInterval => chart_unit_interval,
                        :tickMarksColor => '#888888',                        
						
					},
					:series => series,
				}
			]					
		}
		return chart
	end
=end
end
