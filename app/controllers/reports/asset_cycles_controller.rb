class Reports::AssetCyclesController < ApplicationController
	before_filter :authenticate_user!	
	layout "web_app"
#	load_and_authorize_resource
# **********************************
# AssetCycleFact Reports
# **********************************
	def index    
		respond_to do |format|		
		  	format.html # index.html.erb
		  	format.json { 		  	
  				render json: JqxConverter.jqxGrid(current_user.entity.visible_asset_cycle_facts.map{|x| {
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
            k: x.start_time.to_i * 1000,
            l: x.fill_time.to_i * 1000,
            m: x.delivery_time.to_i * 1000,
            n: x.pickup_time.to_i * 1000,
            o: x.end_time.to_i * 1000,
            p: x.cycle_complete_description,
            q: x._id
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

	        render json: response 
	      }
	    end    
  	end
  # GET /AssetCycleFacts/new
  # GET /AssetCycleFacts/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = AssetCycleFact.new
        response = {}
        response[:jqxDropDownLists] = {}   
        response[:record] = record              

    		response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList(current_user.entity.skus)
        response[:jqxDropDownLists][:base_AssetCycleFact_tier] = JqxConverter.jqxDropDownList(AssetCycleFact.base_AssetCycleFact_tiers)
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
#        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

        render json: response 
      }
    end    
  end

  # GET /AssetCycleFacts/1/edit
  def edit
    record = AssetCycleFact.find(params[:id])
    respond_to do |format|
      if  1 == 0 # can? :update, record
        format.html {render :layout => 'popup'}
        format.json { 
           response = {}
#          response[:jqxDropDownLists] = {}                  
 #         response[:record] = record 
#
 #         response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList(current_user.entity.skus)                                        
  #        response[:jqxDropDownLists][:base_AssetCycleFact_tier] = JqxConverter.jqxDropDownList(AssetCycleFact.base_AssetCycleFact_tiers)
   #       response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
#          response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

          render json: response 
        }        
      else
        format.html {redirect_to :action => 'show'}
      end
    end
  end

  # POST /AssetCycleFacts
  # POST /AssetCycleFacts.json
  def create
    record = AssetCycleFact.new(params[:record])
    respond_to do |format|
      if record.save
        format.html 
        format.json {  render json: {} }
      else
        format.html { render action: "new" }
        format.json {  render json: {} }
      end
    end
  end

  # PUT /AssetCycleFacts/1
  # PUT /AssetCycleFacts/1.json
  def update
    record = AssetCycleFact.find(params[:id])
    record.update_attributes(params[:record])
    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
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
end
