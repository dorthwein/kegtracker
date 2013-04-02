class Reports::AssetActivityFactsController < ApplicationController
  before_filter :authenticate_user!
  layout "web_app"
  load_and_authorize_resource
  # GET /Invoices
  # GET /Invoices.json  
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json {
      	
        if params[:asset_cycle_id].nil?
			     records = JqxConverter.jqxGrid(current_user.entity.visible_asset_activity_facts)
        else
#        	asset_cycle_fact = AssetCycleFact.find(params[:asset_cycle_id])
#       	records = AssetActivityFact.where(asset_cycle_fact_id: asset_cycle_fact._id)
	        records = JqxConverter.jqxGrid(current_user.entity.visible_asset_activity_facts.where(:asset_cycle_fact_id => params[:asset_cycle_id]))
	    end	     
        render json: records
      }
    end
  end
end
