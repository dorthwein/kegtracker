class Reports::AssetCyclesController < ApplicationController
=begin
	before_filter :authenticate_user!	
	layout "web_app"
	load_and_authorize_resource :class => "AssetCycleFact"
# **********************************
# AssetCycleFact Reports
# **********************************
	def index    
		respond_to do |format|		
		  	format.html # index.html.erb
		  	format.json { 		  	
          start = Time.now - (86400 * 180)
  				render json: JqxConverter.jqxGrid(current_user.entity.visible_asset_cycle_facts.where(cycle_complete: 0).map{|x| {
            a: x.start_network_description,
            b: x.fill_network_description,
            c: x.delivery_network_description,
            d: x.pickup_network_description,
            e: x.end_network_description,
            f: x.product_description,
            g: x.product_entity_description,
            h: x.asset_type_description,
            i: x.asset_status_description,
            j: x.handle_code_description,

            k: x.start_time != nil ? x.start_time.to_i * 1000 : nil,
            l: x.fill_time != nil ? x.fill_time.to_i * 1000 : nil,
            m: x.delivery_time != nil ? x.delivery_time.to_i * 1000 : nil,
            n: x.pickup_time != nil ? x.pickup_time.to_i * 1000 : nil,
            o: x.end_time != nil ? x.end_time.to_i * 1000 : nil,

            p: x.cycle_complete_description,
            q: x._id,
            r: x.batch_number,
          }})
  			}
		end
	end  

  	def show
	    respond_to do |format|
	      format.html {render :layout => 'popup'}
	      format.json { 
	        
	         record = AssetCycleFact.find(params[:id])        
	         response = {}
	         response[:jqxDropDownLists] = {}      
           response[:jqxRecordLinkButton] = {}      
	         response[:record] = record  

           response[:jqxRecordLinkButton][:asset_id] = JqxConverter.jqxRecordLinkButton(record.asset_id)
  			   response[:jqxDropDownLists][:product_id] = JqxConverter.jqxDropDownList([record.product])
  			   response[:jqxDropDownLists][:product_entity_id] = JqxConverter.jqxDropDownList([record.product.entity])
  			   response[:jqxDropDownLists][:asset_type_id] = JqxConverter.jqxDropDownList([record.asset_type])
  			   response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([record.asset.entity])
           response[:jqxGrid] = current_user.entity.visible_asset_activity_facts.where(:asset_cycle_fact => record)
	        render json: response 
	      }
	    end    
  	end
  # GET /AssetCycleFacts/new
  # GET /AssetCycleFacts/new.json

  # GET /AssetCycleFacts/1/edit
  def edit
    respond_to do |format|
        format.html {redirect_to :action => 'show'}
    end
  end
  # DELETE /AssetCycleFacts/1
  # DELETE /AssetCycleFacts/1.json
  def destroy
    record = AssetCycleFact.find(params[:id])
    record.destroy

    respond_to do |format|    
      format.json { head :no_content }
    end
  end
=end
end
