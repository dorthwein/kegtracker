class Api::V1::AssetTypesController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_filter :authenticate_user!

  def index	  
	asset_types = { :table => :asset_types, :data => get_asset_types }	
    respond_to do |format|
      	format.json { render json: asset_types  }
	end
  end

end
