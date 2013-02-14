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
  	entity_partnership = EntityPartnership.find(params[:_id])
	  production_entities = JqxConverter.jqxDropDownList(Entity.production_entities)
    contractee = JqxConverter.jqxDropDownList([current_user.entity])

    response = {:partners => production_entities, :entities => contractee, :entity_partnership => entity_partnership }    
    respond_to do |format|
      format.json { render json: response }
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
	  production_entities = JqxConverter.jqxDropDownList(Entity.production_entities)
    contractee = JqxConverter.jqxDropDownList([current_user.entity])
    
    response = {:partners => production_entities, :entities => contractee }
    respond_to do |format|
      format.json { render json: response }
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
          entity_partnership = EntityPartnership.find_or_create_by(  :entity_id => params[:entity_partnership][:entity_id], 
                                                :partner_id => params[:entity_partnership][:partner_id],
                                              )
          entity_partnership.update_attributes(:production_partnership => 1)
          print entity_partnership.to_json
          render json: entity_partnership
      }
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update	
    respond_to do |format|
      format.json {
        entity_partnership = EntityPartnership.find(params[:id])
        if entity_partnership.update_attributes(params[:entity_partnership])
          render json: entity_partnership
        else
          render json: {:sucess => false, :message => 'Location update error, please contact support'}
        end
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
