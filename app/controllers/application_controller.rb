class ApplicationController < ActionController::Base
	protect_from_forgery
	layout :layout_by_resource

	rescue_from CanCan::AccessDenied do |exception|
		redirect_to :access_denied, :alert => exception.message
	end	
	def layout_by_resource
		if devise_controller?
	  		"public"
		else
			"application"
		end 
	end

end
