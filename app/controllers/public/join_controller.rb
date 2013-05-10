class Public::JoinController < ApplicationController
#	before_filter :authenticate_user!	
	def index
		respond_to do |format|
        	format.html {render :layout => 'public'}
    	end
	end
	
	# Reponds to Post
	def create
		respond_to do |format|          
			format.json { 				
				user = User.where(:email => params[:user][:email]).first
				if user.nil?
					params[:user]
					params[:user][:operation] = 1
					params[:user][:account] = 1
					params[:user][:financial] = 1
					
					user = User.create!(params[:user])
					params[:entity][:mode] = 1
					entity = Entity.create!(params[:entity])
					user.entity_id = entity._id
					entity.keg_tracker = 1
					
				end

				if user.save! && entity.save!
			  		response = {:success => true}
			  	else
			  		response = {:success => false}
			  	end
			  	render json: response
		  	}        
		end	
	end
end
