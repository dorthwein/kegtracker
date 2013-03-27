class Public::MembersController < ApplicationController
	before_filter :authenticate_user!
	layout "public"
	def index
		respond_to do |format|
        	format.html
    	end
	end
	
end
