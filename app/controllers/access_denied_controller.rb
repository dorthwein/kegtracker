class AccessDeniedController < ApplicationController
  before_filter :authenticate_user!
  layout "web_app"

  def index
#	@network_memberships = NetworkMembership.where(:entity_id => current_user.entity._id, :asset_distribution => true)	
    respond_to do |format|
      format.html # index.html.erb
    end
  end		
  def popup_record_not_found
    respond_to do |format|
      format.html {render :layout => 'popup'}
    end
  end		

end
