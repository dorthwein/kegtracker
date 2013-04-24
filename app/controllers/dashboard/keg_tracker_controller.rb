class Dashboard::KegTrackerController < ApplicationController
	before_filter :authenticate_user!	
	layout "web_app"
	def index			
		respond_to do |format|  
			format.html	
			format.json { 				
				render json: { :recent_activity_data => 'test'}
			}
		end
	end
end
