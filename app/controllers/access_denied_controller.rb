class AccessDeniedController < ApplicationController
  before_filter :authenticate_user!
  layout "web_app"

  def index
    respond_to do |format|
      format.html {render :layout => 'popup'}
    end
  end		

  def popup_record_not_found
    respond_to do |format|
      format.html {render :layout => 'popup'}
    end
  end		

end
