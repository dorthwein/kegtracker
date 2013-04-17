class Account::BreweryAppsInvoicesController < ApplicationController
	before_filter :authenticate_user!	
	layout "web_app"
	def index
		respond_to do |format|
        	format.html
		    format.json { 		     
		    	records = BreweryAppsInvoice.where(bill_to_entity_id: current_user.entity._id).map{|x| {
		    		a: x.billing_period_month.to_s + '/' + x.billing_period_year.to_s,
		    		b: x.total,
		    		c: x.get_status_description,
		    		d: x._id
		    	}}
		      	render json: JqxConverter.jqxGrid(records)
		    }
    	end
	end
	def show		
		@invoice = BreweryAppsInvoice.find(params[:id]);
		respond_to do |format|
        	format.html
    	end		
	end	
end
