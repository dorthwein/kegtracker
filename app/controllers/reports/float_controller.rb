class Reports::FloatController < ApplicationController
	before_filter :authenticate_user!	
# **********************************
# Float  Health Reports
# **********************************
	def activity_summary_report
		respond_to do |format|
			format.html 
		    format.json { 
			    render json: @response 
			}
		end				
	end	
	def life_cycle_summary_report
		respond_to do |format|  
			format.html
		    format.json { 
		    	render json: @response 
			}			
		end			
	end	
end
