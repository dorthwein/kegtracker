class Maintenance::DistributionPartnershipsController < ApplicationController
  before_filter :authenticate_user!
  layout "web_app"
#  load_and_authorize_resource

  def index    		
    respond_to do |format|
      format.html # index.html.erb
      format.json {      	
	      records = JqxConverter.jqxGrid(current_user.entity.distribution_partnerships)
	     	render json: records
      }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    respond_to do |format|
      record = DistributionPartnership.find(params[:id])     
      if can? :update, record 
        format.html {redirect_to :action => 'edit'}
      else       
        format.html {render :layout => 'popup'}
        format.json { 
        response = {}
          response[:jqxDropDownLists] = {}        
          response[:record] = record              
          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])    
          response[:jqxDropDownLists][:partner_id] = JqxConverter.jqxDropDownList(Entity.distribution_entities)

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
        record = DistributionPartnership.new        
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
        response[:jqxDropDownLists][:partner_id] = JqxConverter.jqxDropDownList(Entity.distribution_entities)
        render json: response 
      }
    end
  end

  # GET /locations/1/edit
  def edit    
    respond_to do |format|      
      format.html {render :layout => 'popup'}
      format.json { 
        record = DistributionPartnership.find(params[:id])
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])    
        response[:jqxDropDownLists][:partner_id] = JqxConverter.jqxDropDownList(Entity.distribution_entities)

        render json: response 
      }        
    end
  end

  # POST /locations
  # POST /locations.json
  def create
    respond_to do |format|          
      format.json { 
      	record = DistributionPartnership.find_or_create_by(:entity_id => params[:record][:entity_id], :partner_id => params[:record][:partner_id])
#        entity_partnership = EntityPartnership.where(:entity_id => params[:record][:entity_id], :partner_id => params[:record][:partner_id]).first
#        if entity_partnership.nil?
        	# If nil, create
#        	entity_partnership = EntityPartnership.new(  params[:record])
#          entity_partnership.distribution_partnership = 1
#        else
#        	entity_partnership.distribution_partnership = 1        	
#        end               
          record.save
          render json: record
      }        
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update	
    record = DistributionPartnership.find(params[:id])
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
  # Intentionally Delete
  def destroy
    record = DistributionPartnership.find(params[:id])
    record.destroy
    respond_to do |format|    
      format.json { head :no_content }
    end
  end
end
