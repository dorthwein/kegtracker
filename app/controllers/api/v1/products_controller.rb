=begin
class Api::V1::ProductsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_filter :authenticate_user!

  def index	  
	products = { :table => :products, :data => get_products }	
    respond_to do |format|
      	format.json { render json: products  }
	end
  end
end
=end