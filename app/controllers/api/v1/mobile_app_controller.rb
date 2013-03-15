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
		  	user = User.where(:authentication_token => params[:auth_token]).first

		  	response = {db: {sync: {}} }
		  	response[:db][:sync][:asset_types] = AssetType.all
		  	response[:db][:sync][:locations] = user.entity.visible_locations
		  	response[:db][:sync][:assets] = user.entity.visible_assets
		  	response[:db][:sync][:products] = user.entity.production_products		  
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
