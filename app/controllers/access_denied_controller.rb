class AccessDeniedController < ApplicationController
  def index
#	@network_memberships = NetworkMembership.where(:entity_id => current_user.entity._id, :asset_distribution => true)	
    respond_to do |format|
      format.html # index.html.erb
    end
  end		
end
