class HomeController < ApplicationController	
  def index	
    respond_to do |format|
	  if user_signed_in?
		  format.html { redirect_to :dashboard_viewer }    	  			
	  else
#	 	format.html { redirect_to new_user_session_path, notice: 'Please Login.' } 
		format.html { redirect_to public_home_path, notice: 'Please Login.' } 
	  end
    end
  end
end
