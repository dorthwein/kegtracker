class Maintenance::ProductsController < ApplicationController
  before_filter :authenticate_user!
  
  load_and_authorize_resource
  # GET /products
  # GET /products.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        products = JqxConverter.jqxGrid(current_user.entity.products.where(record_status: 1))
        render json: products
      }
    end
  end
  # GET /products/1
  # GET /products/1.json
  def show
    @record = Product.find(params[:id])        
    @product_types = ProductType.all
    @entities = [current_user.entity]

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

  # GET /products/new
  # GET /products/new.json
  def new
    @record = Product.new    
    @product_types = ProductType.all
    @entities = [current_user.entity]

    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json {         
        response = {}
        render json: response 
      }
    end    
  end

  # GET /products/1/edit
  def edit
    @record = Product.find(params[:id])        
    @product_types = ProductType.all
    @entities = [current_user.entity]

    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        response = {}
        render json: response 
      }        
    end
  end

  # POST /products
  # POST /products.json
  def create
    @record = Product.new(params[:product])
    @record.save!
    respond_to do |format|    
      format.html { head :no_content}
      format.json {  render json: {} }
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    @record = Product.find(params[:id])
    @record.update_attributes(params[:product])
    
    respond_to do |format|
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @record = Product.find(params[:id])
    @record.trash
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def restore_multiple
    respond_to do |format|    
      @records = Product.where(:id.in => params[:ids])      
      @records.restore
      format.json { 
        render json: @records
      }
    end
  end

  def delete_multiple
    respond_to do |format|    
      @records = Product.where(:id.in => params[:ids])      
      @records.trash
      format.json { 
        render json: @records
      }
    end
  end
end

















