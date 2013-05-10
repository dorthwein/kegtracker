class Reports::Distributors::AuditController < ApplicationController

	def index
	    respond_to do |format|
	      format.html # index.html.erb
	      format.json {                 
	          
	          render json: locations          
	      }
	    end
	end
end
