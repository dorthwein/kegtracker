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
        print params[:asset_cycle_id].to_s + 'fuck'
        if params[:asset_cycle_id].nil?
			     records = current_user.entity.visible_asset_activity_facts
        else
	        records = current_user.entity.visible_asset_activity_facts.where(:asset_cycle_fact_id => params[:asset_cycle_id])
	    end	     
        render json: JqxConverter.jqxGrid(records)
      }
    end
  end
end
