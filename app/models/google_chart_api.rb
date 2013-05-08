class GoogleChartApi

=begin
		  	format.json {          
          cols = [
            {:id => :entity_description, label: 'Owner', type: 'string'},    
            {:id => :product_description, label: 'Product', type: 'string'},    
            {:id => :asset_type_description, label: 'Size', type: 'string'},    
            {:id => :product_entity_description, label: 'Brewer', type: 'string'},    
            {:id => :fill_time, label: 'Fill Date', type: 'date'},    
            {:id => :tag_value, label: 'Tag', type: 'string'},            
            {:id => :asset_status_description, label: 'Status', type: 'string'},                
            {:id => :location_description, label: 'Location', type: 'string'},                
            {:id => :location_network_description, label: 'Location Network', type: 'string'},                
            {:id => :last_action_time, label: 'Last Seen', type: 'date'},                
            {:id => :_id, label: 'View', type: 'string'},                
            {:id => :asset_cycle_fact_id, label: 'Cycle', type: 'string'}
          ]
          source = current_user.entity.visible_assets
          
          render json: GoogleChartApi.table(source, cols)
			  }
=end			  
	def self.table source, columns
		data_table = {}
		data_table['cols'] = columns
		data_table['rows'] = []
		rows_map = source.map{|x|
			row_cells = []
			data_table['cols'].each do |v|
#				print x[v[:id]].to_s + "\n"
				if v[:type] == 'date' && !x[v[:id]].nil?
					row_cells.push(	{
						v: "Date(#{  x[v[:id]].to_i * 1000  })"
					})

				elsif v[:type] == 'number' && !x[v[:id]].nil?
					row_cells.push(
						{v: x[v[:id]].to_f	}
					)				
				else

					#row_cells.push({v: 1.2})				
					row_cells.push({v: x[v[:id]]})				
				end

			end
			data_table['rows'].push({c: row_cells})
		}
		
		print data_table.to_json
		return data_table
	end
end
