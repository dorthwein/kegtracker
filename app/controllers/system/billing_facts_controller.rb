class System::BillingFactsController < ApplicationController
	before_filter :authenticate_user!	
	layout "web_app"
	def index
	    respond_to do |format|
	      format.html # index.html.erb
	      format.json { 
	        entity = Entity.find(params[:entity_id])        	       	        
	        records = JqxConverter.jqxGrid(BillingFact.where(bill_to_entity_id: entity._id))

	        render json: records
	      }
	    end
	end
end
