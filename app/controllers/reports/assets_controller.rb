class Reports::AssetsController < ApplicationController	
	before_filter :authenticate_user!	
	layout "web_app"
#	load_and_authorize_resource
# **********************************
# Asset Reports
# **********************************
	def index    

		respond_to do |format|		
		  	format.html # index.html.erb
		  	format.json {
  				render json: JqxConverter.jqxGrid(current_user.entity.visible_assets.map{ |x| {
            a: x.entity_description,
            b: x.product_entity_description,
            c: x.tag_value,
            d: x.asset_type_description,
            e: x.asset_status_description,
            f: x.product_description,
            g: x.location_description,
            h: x.location_network_description,
            i: x._id,
            j: x.fill_time.to_i * 1000,
            k: x.last_action_time.to_i * 1000,
            l: x.asset_cycle_fact_id,                    
          }});
			  }
		end
	end  
  	def show
	    respond_to do |format|
	      format.html {render :layout => 'popup'}
	      format.json { 
	        
		      record = Asset.find(params[:id])        
		      response = {}
	    	  response[:jqxDropDownLists] = {}            
	      	  response[:jqxRecordLinkButton] = {}
	      
	      response[:record] = record  
	      if !record.invoice.nil?
	      	response[:record][:invoice_date] = record.invoice.date
	      else
	      	response[:record][:invoice_date] = nil				   
	      end
			response[:jqxRecordLinkButton][:asset_cycle_fact_id] = JqxConverter.jqxRecordLinkButton(record.asset_cycle_fact_id)
			response[:jqxDropDownLists][:product_id] = JqxConverter.jqxDropDownList([record.product])
			response[:jqxDropDownLists][:product_entity_id] = JqxConverter.jqxDropDownList([record.product.entity])
			response[:jqxDropDownLists][:asset_type_id] = JqxConverter.jqxDropDownList([record.asset_type])
			response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([record.entity])

#	        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

	        render json: response 
	      }
	    end    
  	end

  # GET /Assets/new
  # GET /Assets/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = Asset.new
        response = {}
        response[:jqxDropDownLists] = {}   
        response[:record] = record              

		response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList(current_user.entity.skus)
        response[:jqxDropDownLists][:base_Asset_tier] = JqxConverter.jqxDropDownList(Asset.base_Asset_tiers)
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
#        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

        render json: response 
      }
    end    
  end

  # GET /Assets/1/edit
  def edit
    record = Asset.find(params[:id])
    respond_to do |format|
      if  1 == 0 # can? :update, record
        format.html {render :layout => 'popup'}
        format.json { 
          response = {}
          response[:jqxDropDownLists] = {}                  
          response[:record] = record 

          response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList(current_user.entity.skus)                                        
          response[:jqxDropDownLists][:base_Asset_tier] = JqxConverter.jqxDropDownList(Asset.base_Asset_tiers)
          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
#          response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

          render json: response 
        }        
      else
        format.html {redirect_to :action => 'show'}
      end
    end
  end

  # POST /Assets
  # POST /Assets.json
  def create
    record = Asset.new(params[:record])
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

  # PUT /Assets/1
  # PUT /Assets/1.json
  def update
    record = Asset.find(params[:id])
    record.update_attributes(params[:record])
    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /Assets/1
  # DELETE /Assets/1.json
  def destroy
    record = Asset.find(params[:id])
    record.destroy

    respond_to do |format|    
      format.json { head :no_content }
    end
  end

	def sku_summary_report_simple
		respond_to do |format|  
			format.html
		    format.json {
				
				date = DateTime.parse(params['date'])

				start_date = date.beginning_of_day
				end_date = date.end_of_day
												
				facts = JqxConverter.jqxGrid(current_user.entity.network_facts.between(fact_time: start_date..end_date)).any_of(
					{:empty_quantity.gt => 0},
					{:full_quantity.gt => 0},
					{:market_quantity.gt => 0},
					{:total_quantity.gt => 0}
				)
		    	response = {:grid => facts} #, :location_networks => location_network_list}
		 
		    render json: response
		}
		end			
	end	
end

