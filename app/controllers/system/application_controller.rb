class ApplicationController < ActionController::Base
end

class System::ApplicationController < ApplicationController 
  # these goes in your namespace admin folder
  before_filter :check_authorized
  def check_authorized
    redirect_to :access_denied unless can? :system_admin, :all
  end
end
