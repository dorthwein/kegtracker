class Public::TermsOfUseController < ApplicationController
#	before_filter :authenticate_user!
	
	def index
		respond_to do |format|
        	format.html {render :layout => 'public'}
    	end
	end
end
