class ApplicationController < ActionController::Base
	protect_from_forgery
	before_filter :check_browser
	before_filter :layout_by_resource

	rescue_from CanCan::AccessDenied do |exception|
		redirect_to :access_denied, :alert => exception.message
	end	

	def layout_by_resource
		if devise_controller?
	  		self.class.layout 'public'
		else				
			x = params[:ajax_load]
		    if (params[:ajax_load].to_i == 1) == true		    	
		    	self.class.layout false
		    else
				self.class.layout 'web_app'
		    end
		end 
	end

	def check_browser
		user_agent = UserAgent.parse(request.user_agent)
		
		print self.class.to_s.split("::").first
		#print self.class.to_s != 'AccessDeniedController'
		if self.class.to_s.split("::").first != 'Public'
			if self.class.to_s.split("::").first != 'AccessDeniedController' && user_agent.browser == 'Internet Explorer'
				redirect_to :bad_browser #, :alert => exception.message
			end
		end

=begin
		browser.name        # readable browser name
		browser.safari?
		browser.opera?
		browser.chrome?
		browser.mobile?
		browser.tablet?
		browser.firefox?
		browser.ie?
		browser.ie6?        # this goes up to 9
		browser.capable?    # supports some CSS 3
		browser.platform    # return :mac, :windows, :linux or :other
		browser.mac?
		browser.windows?
		browser.linux?
		browser.blackberry?
		browser.meta        # an array with several attributes
		browser.to_s        # the meta info joined by space	
=end				
	end
end



