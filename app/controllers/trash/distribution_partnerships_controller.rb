class Trash::DistributionPartnershipsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index    		
    respond_to do |format|
      format.html # index.html.erb
      format.json {      	
	      @records = current_user.entity.distribution_partnerships.where(record_status: 0)
	     	render json: @records
      }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    respond_to do |format|
      @record = DistributionPartnership.find(params[:id])
      @entities = [current_user.entity]  
      @partners = Entity.distribution_entities

      if can? :update, @record 
        format.html {redirect_to :action => 'edit'}
      else       
        format.html {render :layout => 'popup'}
        format.json { 
          response = {}
          render json: response 
        }
      end
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    @record = DistributionPartnership.new        
    @entities = [current_user.entity]  
    @partners = Entity.distribution_entities

    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        response = {}
        render json: response 
      }
    end
  end

  # GET /locations/1/edit
  def edit    
    @record = DistributionPartnership.find(params[:id])     
    @entities = [current_user.entity]  
    @partners = Entity.distribution_entities

    respond_to do |format|      
      format.html {render :layout => 'popup'}
      format.json { 
        response = {}
        render json: response 
      }        
    end
  end

  # POST /locations
  # POST /locations.json
  def create
    respond_to do |format|          
      format.json { 
      	@record = DistributionPartnership.find_or_create_by(:entity_id => params[:distribution_partnership][:entity_id], :partner_id => params[:distribution_partnership][:partner_id])
        @record.update_attribute(:record_status, 1)
        render json: @record
      }        
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update	
    @record = DistributionPartnership.find(params[:id])
    @record.update_attributes(params[:distribution_partnership])    
    respond_to do |format|    
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  # Intentionally Delete
  def destroy
    @record = DistributionPartnership.find(params[:id])
    @record.trash
    respond_to do |format|    
      format.json { head :no_content }
    end
  end

  def restore_multiple
    respond_to do |format|    
      @records = DistributionPartnership.where(:id.in => params[:ids])      
      @records.restore
      format.json { 
        render json: @records
      }
    end
  end

  def delete_multiple
    respond_to do |format|    
      @records = DistributionPartnership.where(:id.in => params[:ids])      
      @records.trash
      format.json { 
        render json: @records
      }
    end
  end
end

