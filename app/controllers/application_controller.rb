class ApplicationController < ActionController::Base
	protect_from_forgery
	before_filter :layout_by_resource

	rescue_from CanCan::AccessDenied do |exception|
		redirect_to :access_denied, :alert => exception.message
	end	

	def layout_by_resource
		if devise_controller?
	  		self.class.layout 'public'
		else				
			x = params[:ajax_load]
			print params[:ajax_load].to_i.class.to_s + ' fuck' + (params[:ajax_load].to_i == 1).to_s

		    if (params[:ajax_load].to_i == 1) == true
		    	print 'worked'
		    	self.class.layout false
		    else
		    	print 'fails'
				self.class.layout 'web_app'
		    end
		end 
	end
end
