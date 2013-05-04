class Maintenance::PricesController < ApplicationController
=begin
  before_filter :authenticate_user!  
  load_and_authorize_resource

  # GET /Prices
  # GET /Prices.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        records = JqxConverter.jqxGrid(current_user.entity.prices.where(record_status: 1))
        render json: records
      }
    end
  end
  # GET /Prices/1
  # GET /Prices/1.json
  def show
    respond_to do |format|
      record = Price.find(params[:id])        
      if can? :update, record 
        format.html {redirect_to :action => 'edit'}
      else       

        format.html {render :layout => 'popup'}
        format.json { 
        
     
          response = {}
          response[:jqxDropDownLists] = {}            
          response[:record] = record  

  		    response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList(current_user.entity.skus)
          response[:jqxDropDownLists][:base_price_tier] = JqxConverter.jqxDropDownList(Price.base_price_tiers)
  		    response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
  #        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

          render json: response 
        }
      end
    end    
  end

  # GET /Prices/new
  # GET /Prices/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = Price.new
        response = {}
        response[:jqxDropDownLists] = {}   
        response[:record] = record              

		    response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList(current_user.entity.skus)
        response[:jqxDropDownLists][:base_price_tier] = JqxConverter.jqxDropDownList(Price.base_price_tiers)
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
#        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

        render json: response 
      }
    end    
  end

  # GET /Prices/1/edit
  def edit    
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json {
        record = Price.find(params[:id]) 
        response = {}
        response[:jqxDropDownLists] = {}                  
        response[:record] = record 

        response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList(current_user.entity.skus)                                        
        response[:jqxDropDownLists][:base_price_tier] = JqxConverter.jqxDropDownList(Price.base_price_tiers)
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
#          response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

        render json: response 
      }        
    end
  end

  # POST /Prices
  # POST /Prices.json
  def create
    record = Price.new(params[:record])
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

  # PUT /Prices/1
  # PUT /Prices/1.json
  def update
    record = Price.find(params[:id])
    record.update_attributes(params[:record])
    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /Prices/1
  # DELETE /Prices/1.json
  def destroy
    record = Price.find(params[:id])
    record.trash
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def restore_multiple
    respond_to do |format|    
      records = Price.where(:id.in => params[:ids])      
      records.restore
      format.json { 
        render json: records
      }
    end
  end

  def delete_multiple
    respond_to do |format|    
      records = Price.where(:id.in => params[:ids])      
      records.trash
      format.json { 
        render json: records
      }
    end
  end
=end
end

















