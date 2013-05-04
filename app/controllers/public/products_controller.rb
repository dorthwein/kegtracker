class Public::ProductsController < ApplicationController	
	def index
		respond_to do |format|
        	format.html {render :layout => 'public'}
    	end
	end
end
