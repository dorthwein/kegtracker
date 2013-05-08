class Reports::Assets::TimeAtLocationController < ApplicationController
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
			        {:id => :days_at_location_sample_size, label: 'Sample Size',  type: 'number' },
			        {:id => :days_at_location_avg, label: 'Avg Days at Location',  type: 'number' },

			        {:id => :fact_time, label: 'Date', type: 'date'},
		        ]
		        source = current_user.entity.visible_daily_facts.where(:days_at_location_sample_size.gt => 0)
		        render json: GoogleChartApi.table(source, cols)
		    }		
		end
	end
end
