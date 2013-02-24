class Public::ContactController < ApplicationController
	before_filter :authenticate_user!
	def index
		respond_to do |format|
        	format.html
    	end
	end

	def create
		respond_to do |format|          
		  format.json { 
		  	if Registration.create(params[:registration])
		  		response = {:success => true}
		  	else
		  		response = {:success => false}
		  	end
		  	render json: response
		  }        
		end	
	end	
end
