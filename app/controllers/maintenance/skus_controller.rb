class Maintenance::SkusController < ApplicationController
  before_filter :authenticate_user!
  layout "web_app"
  load_and_authorize_resource
 

  # GET /skus
  # GET /skus.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        records = JqxConverter.jqxGrid(current_user.entity.skus)
        render json: records
      }
    end
  end

  # GET /skus/1
  # GET /skus/1.json
  def show
    respond_to do |format|
      record = Sku.find(params[:id])              
      if can? :update, record 
        format.html {redirect_to :action => 'edit'}
      else       

        format.html {render :layout => 'popup'}
        format.json {   
          response = {}
          response[:jqxDropDownLists] = {}        
          response[:record] = record              
          response[:jqxDropDownLists][:product_id] = JqxConverter.jqxDropDownList(current_user.entity.products)
          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
          response[:jqxDropDownLists][:primary_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.all)
          response[:jqxDropDownLists][:tier_1_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.where(:tier_1 => 1))
          response[:jqxDropDownLists][:tier_2_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.where(:tier_2 => 1))
          response[:jqxDropDownLists][:tier_3_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.where(:tier_3 => 1))
          response[:jqxDropDownLists][:tier_4_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.where(:tier_4 => 1))
  
          render json: response 
        }
      end
    end  
  end

  # GET /skus/new
  # GET /skus/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = Sku.new
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:product_id] = JqxConverter.jqxDropDownList(current_user.entity.products)
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
        response[:jqxDropDownLists][:primary_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.all)
        response[:jqxDropDownLists][:tier_1_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.where(:tier_1 => 1))
        response[:jqxDropDownLists][:tier_2_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.where(:tier_2 => 1))
        response[:jqxDropDownLists][:tier_3_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.where(:tier_3 => 1))
        response[:jqxDropDownLists][:tier_4_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.where(:tier_4 => 1))

        render json: response 
      }
    end  
  end

  # GET /skus/1/edit
  def edit
    respond_to do |format|
        format.html {render :layout => 'popup'}
        format.json { 
          record = Sku.find(params[:id])
          response = {}
          response[:jqxDropDownLists] = {}        
          response[:record] = record              
          response[:jqxDropDownLists][:product_id] = JqxConverter.jqxDropDownList(current_user.entity.products)
          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
          response[:jqxDropDownLists][:primary_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.all)
          response[:jqxDropDownLists][:tier_1_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.where(:tier_1 => 1))
          response[:jqxDropDownLists][:tier_2_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.where(:tier_2 => 1))
          response[:jqxDropDownLists][:tier_3_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.where(:tier_3 => 1))
          response[:jqxDropDownLists][:tier_4_asset_type_id] = JqxConverter.jqxDropDownList(AssetType.where(:tier_4 => 1))

          render json: response 
        }        
    end
  end

  # POST /skus
  # POST /skus.json
  def create
    record = Sku.new(params[:record])
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

  # PUT /skus/1
  # PUT /skus/1.json
  def update
    record = Sku.find(params[:id])
    record.update_attributes(params[:record])
    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /skus/1
  # DELETE /skus/1.json
  def destroy
    record = Sku.find(params[:id])
    record.destroy

    respond_to do |format|    
      format.json { head :no_content }
    end
  end
end
