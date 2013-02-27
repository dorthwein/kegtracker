class Maintenance::ProductsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /products
  # GET /products.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        products = JqxConverter.jqxGrid(current_user.entity.products)
        render json: products
      }
    end
  end
  # GET /products/1
  # GET /products/1.json
  def show
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = Product.find(params[:id])        
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:product_type_id] = JqxConverter.jqxDropDownList(ProductType.all)
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])

        render json: response 
      }
    end    
  end

  # GET /products/new
  # GET /products/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = Product.new
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:product_type_id] = JqxConverter.jqxDropDownList(ProductType.all)
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        

        render json: response 
      }
    end    
  end

  # GET /products/1/edit
  def edit
    # Not Active
  end

  # POST /products
  # POST /products.json
  def create
    record = Product.new(params[:record])
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

  # PUT /products/1
  # PUT /products/1.json
  def update
    record = Product.find(params[:id])
    record.update_attributes(params[:record])
    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    product = Product.find(params[:id])
    product.destroy

    respond_to do |format|    
      format.json { head :no_content }
    end
  end
end
