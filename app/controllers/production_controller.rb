class ProductionController < ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource

    respond_to do |format|
      format.html # index.html.erb
    end
end
