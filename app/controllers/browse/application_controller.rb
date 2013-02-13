
class Browse::ApplicationController < ApplicationController 
=begin
  before_filter :check_browse_menu
  def check_browse_menu
    redirect_to :access_denied unless can? :browse_menu, :all
  end
=end
end

