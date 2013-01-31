class ApplicationController < ActionController::Base

end

class Maintenance::ApplicationController < ApplicationController 
  before_filter :check_authorized
  def check_authorized
    redirect_to :access_denied unless can? :maintenance_menu, :all
  end
end
