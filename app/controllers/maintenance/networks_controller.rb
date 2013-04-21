class Maintenance::NetworksController < ApplicationController
  before_filter :authenticate_user!
  layout "web_app"
  load_and_authorize_resource
  # GET /networks
  # GET /networks.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json {       	
        networks = JqxConverter.jqxGrid(current_user.entity.networks.where(record_status: 1))
        render json: networks                   
      }
    end
  end


  # GET /networks/1
  # GET /networks/1.json
  def show
    respond_to do |format|
      record = Network.find(params[:id])        
      if can? :update, record 
        format.html {redirect_to :action => 'edit'}
      else       

        format.html {render :layout => 'popup'}
        format.json { 
        
        
          response = {}
          response[:jqxDropDownLists] = {}        
          response[:record] = record              
          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])      
          response[:jqxDropDownLists][:smart_mode_product_id] = JqxConverter.jqxDropDownList(current_user.entity.production_products) 
          response[:jqxDropDownLists][:smart_mode_in_location_id] = JqxConverter.jqxDropDownList(record.locations) 
          response[:jqxDropDownLists][:smart_mode_out_location_id] = JqxConverter.jqxDropDownList(record.locations) 
          response[:jqxDropDownLists][:network_type] = JqxConverter.jqxDropDownList(Network.network_types)

          render json: response 
        }
      end
    end    
  end

  # GET /networks/new
  # GET /networks/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json {         
        record = Network.new
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])      
        response[:jqxDropDownLists][:smart_mode_product_id] = JqxConverter.jqxDropDownList(current_user.entity.production_products) 
        response[:jqxDropDownLists][:smart_mode_in_location_id] = JqxConverter.jqxDropDownList(record.locations) 
        response[:jqxDropDownLists][:smart_mode_out_location_id] = JqxConverter.jqxDropDownList(record.locations) 
        response[:jqxDropDownLists][:network_type] = JqxConverter.jqxDropDownList(Network.network_types)

        render json: response 
      }
    end    
  end

  # GET /networks/1/edit
  def edit
    
    respond_to do |format|
        format.html {render :layout => 'popup'}
        format.json { 
          record = Network.find(params[:id])
          response = {}
          response[:jqxDropDownLists] = {}        
          response[:record] = record              
          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])      
          response[:jqxDropDownLists][:smart_mode_product_id] = JqxConverter.jqxDropDownList(current_user.entity.production_products) 
          response[:jqxDropDownLists][:smart_mode_in_location_id] = JqxConverter.jqxDropDownList(record.locations) 
          response[:jqxDropDownLists][:smart_mode_out_location_id] = JqxConverter.jqxDropDownList(record.locations) 
          response[:jqxDropDownLists][:network_type] = JqxConverter.jqxDropDownList(Network.network_types)

          render json: response 
        }        
    end
  end


  # POST /networks
  # POST /networks.json
  def create
    record = Network.new(params[:record])
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

  # PUT /networks/1
  # PUT /networks/1.json
  def update
    record = Network.find(params[:id])
    record.update_attributes(params[:record])
    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /networks/1
  # DELETE /networks/1.json
  def destroy
    record = Network.find(params[:id])
    record.trash
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def restore_multiple
    respond_to do |format|    
      records = Network.where(:id.in => params[:ids])      
      records.restore
      format.json { 
        render json: records
      }
    end
  end

  def delete_multiple
    respond_to do |format|    
      records = Network.where(:id.in => params[:ids])      
      records.trash
      format.json { 
        render json: records
      }
    end
  end
end

















