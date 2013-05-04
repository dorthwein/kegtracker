class Dashboard::ViewerController < ApplicationController
	before_filter :authenticate_user!	
	
	def index			
		respond_to do |format|  
			format.html	
			format.json { 				
				render json: {:test => 'test'} 	
			}
		end	
	end	
end
