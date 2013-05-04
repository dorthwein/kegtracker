class Maintenance::ProductionPartnershipsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index    		
    respond_to do |format|
      format.html # index.html.erb
      format.json {      		
	      @records = JqxConverter.jqxGrid(current_user.entity.production_partnerships.where(record_status: 1))
      	render json: @records
      }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    @record = ProductionPartnership.find(params[:id])
    @entities = [current_user.entity]
    @partners = Entity.production_entities

    respond_to do |format|
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
    @record = ProductionPartnership.new
    @entities = [current_user.entity]
    @partners = Entity.production_entities

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
    @record = ProductionPartnership.find(params[:id])
    @entities = [current_user.entity]
    @partners = Entity.production_entities

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
        @record = ProductionPartnership.find_or_create_by(:entity_id => params[:production_partnership][:entity_id], :partner_id => params[:production_partnership][:partner_id])
        @record.save!
        render json: @record
      }        
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update
    @record = ProductionPartnership.find(params[:id])
    @record.update_attributes(params[:production_partnership])
    
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
    @record = ProductionPartnership.find(params[:id])
    @record.trash
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def restore_multiple
    respond_to do |format|    
      @records = ProductionPartnership.where(:id.in => params[:ids])      
      @records.restore
      format.json { 
        render json: @records
      }
    end
  end

  def delete_multiple
    respond_to do |format|    
      @records = ProductionPartnership.where(:id.in => params[:ids])      
      @records.trash
      format.json { 
        render json: @records
      }
    end
  end
end

















