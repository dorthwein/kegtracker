class Maintenance::AssetsController < ApplicationController

	before_filter :authenticate_user!	
	load_and_authorize_resource
  #load_and_authorize_resource :class => 'NetworkFact'
# **********************************
# Asset Reports
# **********************************
	def index    

		respond_to do |format|		
		  	format.html # index.html.erb
		  	format.json {
          if current_user.system_admin == 1
            assets = Asset.all          
          else
            assets = current_user.entity.visible_assets
          end
          
  				render json: JqxConverter.jqxGrid(assets.map{ |x| {
            a: x.entity_description,
            b: x.product_entity_description,
            c: x.tag_value,
            d: x.asset_type_description,
            e: x.asset_status_description,
            f: x.product_description,
            g: x.location_description,
            h: x.location_entity_description,
            i: x._id,
            j: x.fill_time != nil ? x.fill_time.to_i * 1000 : nil,
            k: x.last_action_time != nil ? x.last_action_time.to_i * 1000 : nil,
#            l: x.asset_cycle_fact_id,                    
            m: x.days_at_location,
            n: x.batch_number,
            o: x.invoice_number,
#            n: x.asset_activity_fact.location_entity_arrival_time != nil ? x.asset_activity_fact.location_entity_arrival_time.to_i * 1000 : nil,
          }});
			  }
		end
	end  

	def show
    @record = Asset.find(params[:id])        
    @products = [@record.product]
    @product_entities = [@record.product.entity]
    @asset_types = [@record.asset_type]
    @entities = [@record.entity]
    @invoice = @record.invoice

    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 	        
	      response = {}
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
        @record = Asset.new
        response = {}
        response[:jqxDropDownLists] = {}   
        response[:@record] = @record              

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
    @record = Asset.find(params[:id])
    respond_to do |format|
      format.html {redirect_to :action => 'show'}    
    end
  end

  # POST /Assets
  # POST /Assets.json
  def create
    @record = Asset.new(params[:@record])
    respond_to do |format|
      if @record.save
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
    @record = Asset.find(params[:id])
    @record.update_attributes(params[:@record])
    
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
    @record = Asset.find(params[:id])
    @record.trash
    respond_to do |format|    
      format.json { head :no_content }
    end
  end
  def delete_multiple
    respond_to do |format|    
      @records = Asset.where(:id.in => params[:ids])      
      @records.trash
      format.json { 
        render json: @records
      }
    end
  end


end
