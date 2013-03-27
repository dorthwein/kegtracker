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
        	asset_cycle_fact = AssetCycleFact.find(params[:asset_cycle_id])
        	records = AssetActivityFact.where(asset_cycle_fact: asset_cycle_fact)

#	        records = JqxConverter.jqxGrid(current_user.entity.visible_asset_activity_facts.where(:asset_cycle_fact_id => params[:active_asset_cycle_id]))
	    end
	    print 'fuck' + records.to_json
        render json: records
      }
    end
  end
end
