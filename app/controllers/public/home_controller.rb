class Public::HomeController < ApplicationController
#	before_filter :authenticate_user!
	layout "public"
	def index
		respond_to do |format|
        	format.html {render :layout => 'public'}
    	end
	end
end
