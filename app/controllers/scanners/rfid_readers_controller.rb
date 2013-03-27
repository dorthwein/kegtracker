class Scanners::RfidReadersController < ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource
	layout "web_app"
  # GET /rfids
  # GET /rfids.json

	def index    
		respond_to do |format|		
		  	format.html # index.html.erb
		  	format.json { 
			  	
				
				# Locations /w my assets
				
				
				rfid_readers = RfidReader.all				
				rfid_readers = rfid_readers.map { |rfid_reader| {						
						:network => rfid_reader.network.description,
						:mac_address => rfid_reader.mac_address,
						:reader_name => rfid_reader.reader_name,
						:_id => rfid_reader._id
					}
				}
			
				render json: rfid_readers 			
		  	}
		end
	end

	def browse_row_select
		respond_to do |format|
			format.json {
#				gatherer = Gatherer.new(current_user.entity)
#				location, product, entity = gatherer.asset_activity_fact_criteria
				response = []
				RfidAntenna.where(:rfid_reader_id => params[:_id]).each do |x|
					physical_location  = 	"<div> <b> Locaction Description: 	</b>	 #{x.physical_location } </div>"
					antenna_number = 		"<div> <b> Ant. #: 			</b>	 #{x.antenna_number} </div>"
					response.push({:value => x._id, :html => '<div style="float:left; width:60%;">' +  physical_location + "</div>" + "<div style='width:20%;float:left'>" +   antenna_number +  "</div>" })
				end
				render json: response
			}
		end
	end
	def antenna_select
		respond_to do |format|
			format.json {	
				

				rfid_antenna = RfidAntenna.find(params[:_id])
				gatherer = Gatherer.new(rfid_antenna.rfid_reader.network.entity)			

				response = {}
				response[:locations] = gatherer.get_locations.map { |location| {:value => location.id, :html => location.description} }
				response[:asset_types] = AssetType.all.map { |asset_type| {:html => asset_type.description, :value => asset_type.id} }	    
				response[:products] = gatherer.get_production_products.map { |product| {:html => product.description + ' (' + product.entity.description + ')' , :value => product.id} }	 

				response[:handle_codes] = [
					{:value => 1, :html => 'Delivery'},
					{:value => 2, :html => 'Pickup'},
					{:value => 3, :html => 'Add'},
					{:value => 4, :html => 'Fill'},
					{:value => 5, :html => 'Move'},
					{:value => 6, :html => 'RFNet'}		
				]				

				response[:current_settings] = { 	
													:location => rfid_antenna.location_id, 
													:asset_type => rfid_antenna.asset_type_id,
													:product => rfid_antenna.product_id,
													:handle_code => rfid_antenna.handle_code 
											}


#				response['locations'] = 
				render json: response
			}
		end
	end
	def antenna_update
		respond_to do |format|
			format.json {	
				rfid_antenna = RfidAntenna.find(params[:_id])
				if rfid_antenna.update_attributes(params)
				 
					render json: rfid_antenna
				else
					render json: {:success => false}
				end
			}
		end
	end
end





