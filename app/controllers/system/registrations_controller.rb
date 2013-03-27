class System::RegistrationsController < ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource
  layout "web_app"


  def index    
    respond_to do |format|
      format.html # index.html.erb

      format.json { 
      	facts = JqxConverter.jqxGrid(Registration.all)
      	response = {:grid => facts}
      	render json: response
      }
    end
  end
end
