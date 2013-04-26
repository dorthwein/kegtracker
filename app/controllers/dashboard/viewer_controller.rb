class Dashboard::ViewerController < ApplicationController
	before_filter :authenticate_user!	
	layout  "public" #"web_app"
	def index			
		respond_to do |format|  
			format.html	
			format.json { 				
				render json: {:test => 'test'} 	
			}
		end	
	end	
end
