class Maintenance::ProductionPartnershipsController < ApplicationController
  before_filter :authenticate_user!

  def index    		
    respond_to do |format|
      format.html # index.html.erb
      format.json {      		
	      entity_partnerships = JqxConverter.jqxGrid(current_user.entity.production_partnerships_as_entity)
      	render json: entity_partnerships
      }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = EntityPartnership.find(params[:id])        
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
        response[:jqxDropDownLists][:partner_id] = JqxConverter.jqxDropDownList(Entity.production_entities)
        response[:jqxDropDownLists][:measurement_unit_id] = 
        render json: response 
      }
    end    
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = EntityPartnership.new
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
        response[:jqxDropDownLists][:partner_id] = JqxConverter.jqxDropDownList(Entity.production_entities)
        response[:jqxDropDownLists][:measurement_unit_id] = 
        render json: response 
      }
    end
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations
  # POST /locations.json
  def create
    respond_to do |format|          
      format.json { 
        entity_partnership = EntityPartnership.where(:entity_id => params[:record][:entity_id], :partner_id => params[:record][:partner_id]).first
        if entity_partnership.nil?
          # If nil, create
          entity_partnership = EntityPartnership.new(  params[:record])
          entity_partnership.production_partnership = 1
        else
          entity_partnership.production_partnership = 1         
        end               
          entity_partnership.save
          render json: entity_partnership
      }        
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update	
    record = EntityPartnership.find(params[:id])
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
  def destroy
    entity_partnership = EntityPartnership.find(params[:id])
   	entity_partnership.production_partnership = 0
	  entity_partnership.save

    respond_to do |format|    
      format.json { head :no_content }
    end
  end
end
