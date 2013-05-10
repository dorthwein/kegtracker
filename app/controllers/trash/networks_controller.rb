class Trash::NetworksController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /networks
  # GET /networks.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json {       	
        networks = JqxConverter.jqxGrid(current_user.entity.networks.where(record_status: 0))
        render json: networks                   
      }
    end
  end


  # GET /networks/1
  # GET /networks/1.json
  def show
    respond_to do |format|
      @record = Network.find(params[:id])
      
      @entities = [current_user.entity]
      @products = current_user.entity.production_products
      @locations = @record.locations
      @network_types = Network.network_types

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

  # GET /networks/new
  # GET /networks/new.json
  def new
    @record = Network.new
    @entities = [current_user.entity]
    @products = current_user.entity.production_products
    @locations = @record.locations
    @network_types = Network.network_types

    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json {         
        response = {}
        render json: response 
      }
    end    
  end

  # GET /networks/1/edit
  def edit
    @record = Network.find(params[:id])
    
    @entities = [current_user.entity]
    @products = current_user.entity.production_products
    @locations = @record.locations
    @network_types = Network.network_types
    
    respond_to do |format|

        format.html {render :layout => 'popup'}
        format.json { 
          response = {}
          render json: response 
        }        
    end
  end


  # POST /networks
  # POST /networks.json
  def create
    @record = Network.new(params[:network])
    @record.save!
    respond_to do |format|       
      format.html { head :no_content }
      format.json {  render json: {} }
    end
  end

  # PUT /networks/1
  # PUT /networks/1.json
  def update
    @record = Network.find(params[:id])
    @record.update_attributes(params[:network])
    
    respond_to do |format|
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /networks/1
  # DELETE /networks/1.json
  def destroy
    @record = Network.find(params[:id])
    @record.trash
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def restore_multiple
    respond_to do |format|    
      @records = Network.where(:id.in => params[:ids])      
      @records.restore
      format.json { 
        render json: @records
      }
    end
  end

  def delete_multiple
    respond_to do |format|    
      @records = Network.where(:id.in => params[:ids])      
      @records.trash
      format.json { 
        render json: @records
      }
    end
  end
end

















