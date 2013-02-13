class Maintenance::ProductionPartnershipsController < ApplicationController
  before_filter :authenticate_user!


  def index    		
    respond_to do |format|
      format.html # index.html.erb
      format.json {      	
	    if current_user.system_admin == 1	    	
	      entity_partnerships = JqxConverter.jqxGrid(EntityPartnership.where(:production_partnership => 1))
	    else
	      entity_partnerships = JqxConverter.jqxGrid(current_user.entity.production_partnerships_as_entity)
	    end
      	render json: entity_partnerships
      }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
  	entity_partnership = EntityPartnership.find(params[:_id])
	  production_entities = JqxConverter.jqxDropDownList(Entity.production_entities)
    if current_user.system_admin == 1
      contractee = JqxConverter.jqxDropDownList(Entity.production_entities)    
    else
      contractee = JqxConverter.jqxDropDownList([current_user.entity])
    end

    response = {:partners => production_entities, :entities => contractee, :entity_partnership => entity_partnership }    
    respond_to do |format|
      format.json { render json: response }
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
	  production_entities = JqxConverter.jqxDropDownList(Entity.production_entities)
    if current_user.system_admin == 1
      contractee = JqxConverter.jqxDropDownList(Entity.production_entities)    
    else
      contractee = JqxConverter.jqxDropDownList([current_user.entity])
    end

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
      	entity_partnership = EntityPartnership.where(:entity_id => params[:entity_partnership][:entity_id], :partner_id => params[:entity_partnership][:partner_id]).first
        if entity_partnership.nil?
        	# If nil, create
        	EntityPartnership.create(	
				:entity_id => params[:entity_partnership][:entity_id], 
				:partner_id => params[:entity_partnership][:partner_id],
				:production_partnership => 1
			)
        else
        	entity_partnership.production_partnership = 1
        	entity_partnership.save
        end               
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
          render json: {:sucess => true}
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
   	entity_partnership.distribution_partnership = 0
	entity_partnership.save

    respond_to do |format|    
      format.json { head :no_content }
    end
  end
end
