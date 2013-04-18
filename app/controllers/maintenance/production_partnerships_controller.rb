class Maintenance::ProductionPartnershipsController < ApplicationController
  before_filter :authenticate_user!
  layout "web_app"
#  load_and_authorize_resource

  def index    		
    respond_to do |format|
      format.html # index.html.erb
      format.json {      		
	      records = JqxConverter.jqxGrid(current_user.entity.production_partnerships)
      	render json: records
      }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    respond_to do |format|
      record = ProductionPartnership.find(params[:id])        
      if can? :update, record 
        format.html {redirect_to :action => 'edit'}
      else           
        format.html {render :layout => 'popup'}
        format.json {           
          response = {}
          response[:jqxDropDownLists] = {}        
          response[:record] = record              
          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
          response[:jqxDropDownLists][:partner_id] = JqxConverter.jqxDropDownList(Entity.production_entities)
          render json: response 
        }
      end
    end    
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = ProductionPartnership.new
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
        response[:jqxDropDownLists][:partner_id] = JqxConverter.jqxDropDownList(Entity.production_entities)
        render json: response 
      }
    end
  end

  # GET /locations/1/edit
  def edit
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        record = ProductionPartnership.find(params[:id])
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
        response[:jqxDropDownLists][:partner_id] = JqxConverter.jqxDropDownList(Entity.production_entities)

        render json: response 
      }        
    end
  end

  # POST /locations
  # POST /locations.json
  def create
    respond_to do |format|          
      format.json { 
        record = ProductionPartnership.find_or_create_by(:entity_id => params[:record][:entity_id], :partner_id => params[:record][:partner_id])
        record.save
        render json: record
      }        
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update
    record = ProductionPartnership.find(params[:id])
    record.update_attributes(params[:record])
    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  # Inetentionally Destroy
  def destroy
    record = ProductionPartnership.find(params[:id])
	  record.destroy
    respond_to do |format|    
      format.json { head :no_content }
    end
  end
end
