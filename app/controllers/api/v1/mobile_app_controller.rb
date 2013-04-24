class Api::V1::MobileAppController < ApplicationController
	before_filter :authenticate_user!
	def sync

#
# 	*********************************
#	* Things coming from the server *
# 	*********************************
#		Asset Types
#		Locations
#		Assets
#		Invoices
#		Products
#		SKUs (Maybe)
#
# DB Schema - Details to buld tables
# Data - []

		respond_to do |format|          
		  format.json {
		  	if !params[:scans].nil?
				Scanner.process_scans({:scans => params[:scans]})
			end
			
			last_sync = Time.parse(params[:last_sync]) rescue (Time.parse('2000-01-01T09:22:54-05:00'))

		  	user = User.where(:authentication_token => params[:auth_token]).first		  	
		  	response = {db: {sync: {}} }
		  	
			if user.operation > 0
		  		response[:keg_tracker] = user.entity.keg_tracker
		  	else
				response[:keg_tracker] = 0
		  	end

		  	response[:db][:sync][:processed_scans] = params[:scan_ids]
		  	response[:db][:sync][:asset_types] = AssetType.gte(updated_at: last_sync)
		  	response[:db][:sync][:locations] = user.entity.visible_locations.map{|x| {  
				_id: x._id, 
				created_at: x.created_at, 
				updated_at: x.updated_at, 
				description: x.description,
				externalID: x.externalID, 
				name: x.name, 
				street: x.street,
				city: x.city,
				state: x.state,
				zip: x.zip, 
				asset_count: user.entity.visible_assets.where(location_id: x._id).count,
				location_type_description: x.location_type_description, 
				entity_description: x.entity_description, 
				network_description: x.network_description,
		  	}}
#		  	response[:db][:sync][:assets] = user.entity.visible_assets.gte(updated_at: last_sync)
		  	response[:db][:sync][:products] = user.entity.production_products.gte(updated_at: last_sync)

			response[:db][:sync][:invoice_line_items] = user.entity.invoice_line_items.gte(updated_at: last_sync)
			response[:db][:sync][:invoices] = user.entity.invoices.gte(updated_at: last_sync)
#		  	response[:db][:sync][:invoice_attached_assets] = []		  

		  	render json: response

		  }
		end					
	end	
	def check_connection
		respond_to do |format|          
		  format.json { 
		  	render json: {connection: 1}
		  }
		end			
	end
end
