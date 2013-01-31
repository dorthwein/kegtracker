class Api::V1::CheckConnectionController < ApplicationController
	skip_before_filter :verify_authenticity_token
	def index
		connection = {:connection => true}
		respond_to do |format|
			format.json { render json: connection }
		end
	end
end
