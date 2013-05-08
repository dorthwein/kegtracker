class Reports::Assets::OverviewController < ApplicationController
	def index
		respond_to do |format|		
		  	format.html # index.html.erb
		    format.json {  
		        cols = [

					{:id => :location_description, label: 'Location', type:'string'},
					{:id => :asset_entity_description, label: 'Owner', type:'string'},
					{:id => :entity_city, label: 'City',  type: 'string' },					
					{:id => :entity_state, label: 'State',  type: 'string' },
					{:id => :product_description, label: 'Product', type:'string'},
					{:id => :asset_type_description, label: 'Size', type:'string'},
					{:id => :asset_status_description, label: 'Status', type:'string'},
					{:id => :location_entity_description, label: 'Asset Holder', type:'string'},		
					{:id => :product_entity_description, label: 'Brewer', type:'string'},		          
			        {:id => :quantity, label: '# Assets',  type: 'number' },

			        {:id => :case_equivalent, label: 'CEs',  type: 'number' },
			        {:id => :fact_time, label: 'Date', type: 'date'},
		        ]

		        @date = Time.new
		        source = current_user.entity.visible_daily_facts.between(fact_time: @date.beginning_of_day..@date.end_of_day)
		        render json: GoogleChartApi.table(source, cols)
		    }		
		end
	end
	def csv

		
	end
end
