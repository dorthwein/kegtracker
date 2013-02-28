class Maintenance::PricesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /Prices
  # GET /Prices.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        prices = JqxConverter.jqxGrid(current_user.entity.prices)
        render json: prices
      }
    end
  end
  # GET /Prices/1
  # GET /Prices/1.json
  def show
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = Price.find(params[:id])        
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record  

		response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList([current_user.entity.skus])                                        
		response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

        render json: response 
      }
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

		response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList([current_user.entity.skus])                    
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

        render json: response 
      }
    end    
  end

  # GET /Prices/1/edit
  def edit
    # Not Active
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
    Price = Price.find(params[:id])
    Price.destroy

    respond_to do |format|    
      format.json { head :no_content }
    end
  end
end

