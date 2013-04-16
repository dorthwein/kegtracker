class Account::BreweryAppsInvoicesController < ApplicationController
	before_filter :authenticate_user!	
	layout "web_app"
	def show
		respond_to do |format|
        	format.html
		    format.json { 
		      entity = Entity.find(params[:entity_id])        	       	        
		      records = JqxConverter.jqxGrid(BreweryAppsInvoice.where(bill_to_entity_id: entity._id))

		      render json: records
		    }
    	end
	end
end
