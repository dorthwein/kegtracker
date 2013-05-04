class Maintenance::SkusController < ApplicationController
  before_filter :authenticate_user!  
  load_and_authorize_resource 

  # GET /skus
  # GET /skus.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        @records = JqxConverter.jqxGrid(current_user.entity.skus.where(record_status: 1))
        render json: @records
      }
    end
  end

  # GET /skus/1
  # GET /skus/1.json
  def show
    @record = Sku.find(params[:id])
    @products = current_user.entity.products
    @entities = [current_user.entity]
    @primary_asset_types = AssetType.all
    @tier_1_asset_types = AssetType.where(:tier_1 => 1)
    @tier_2_asset_types = AssetType.where(:tier_2 => 1)
    @tier_3_asset_types = AssetType.where(:tier_3 => 1)
    @tier_4_asset_types = AssetType.where(:tier_4 => 1)    
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

  # GET /skus/new
  # GET /skus/new.json
  def new
    @record = Sku.new
    @products = current_user.entity.products
    @entities = [current_user.entity]
    @primary_asset_types = AssetType.all
    @tier_1_asset_types = AssetType.where(:tier_1 => 1)
    @tier_2_asset_types = AssetType.where(:tier_2 => 1)
    @tier_3_asset_types = AssetType.where(:tier_3 => 1)
    @tier_4_asset_types = AssetType.where(:tier_4 => 1)    
    
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json {  
        response = {}     
        render json: response 
      }
    end  
  end

  # GET /skus/1/edit
  def edit
    @record = Sku.find(params[:id])
    @products = current_user.entity.products
    @entities = [current_user.entity]
    @primary_asset_types = AssetType.all
    @tier_1_asset_types = AssetType.where(:tier_1 => 1)
    @tier_2_asset_types = AssetType.where(:tier_2 => 1)
    @tier_3_asset_types = AssetType.where(:tier_3 => 1)
    @tier_4_asset_types = AssetType.where(:tier_4 => 1)    
 
    respond_to do |format|
        format.html {render :layout => 'popup'}
        format.json { 

          response = {}
          render json: response 
        }        
    end
  end

  # POST /skus
  # POST /skus.json
  def create
    @record = Sku.new(params[:sku])
    @record.save!
    respond_to do |format|
        format.html { head :no_content }
        format.json {  render json: {} }
    end
  end

  # PUT /skus/1
  # PUT /skus/1.json
  def update
    @record = Sku.find(params[:id])
    @record.update_attributes(params[:sku])    
    respond_to do |format|      
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /skus/1
  # DELETE /skus/1.json
  def destroy
    @record = Sku.find(params[:id])
    @record.trash
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def restore_multiple
    respond_to do |format|    
      @records = Sku.where(:id.in => params[:ids])      
      @records.restore
      format.json { 
        render json: @records
      }
    end
  end

  def delete_multiple
    respond_to do |format|    
      @records = Sku.where(:id.in => params[:ids])      
      @records.trash
      format.json { 
        render json: @records
      }
    end
  end
end

















