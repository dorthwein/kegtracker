class Api::V1::LocationsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_filter :authenticate_user!

  def index	  
	locations = { :table => :locations, :data => get_locations }	
    respond_to do |format|
      	format.json { render json: locations  }
	end
  end
end
