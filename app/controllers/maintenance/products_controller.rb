class Maintenance::ProductsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /products
  # GET /products.json
  def index
	# Construct Product Array
	# Current User's Entity's Products
  #	Need to include partner Products
  # @products = Product.all
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
      product_types = JqxConverter.jqxDropDownList(ProductType.all)

      product = Product.find(params[:id])
      response = {:product => product, :product_types => product_types }
      format.json { 
          render json: response 
      }
    end
  end

  # GET /products/new
  # GET /products/new.json
  def new
    respond_to do |format|
      product_types = JqxConverter.jqxDropDownList(ProductType.all)
      response = {:product_types => product_types }
      format.json { 
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
    respond_to do |format|          
      format.json { 
        product = Product.new(params[:product])
        if product.save
          render json: product
        else
          render json: {:success => false, :message => 'Product creation error, please contact support'}
        end
      }        
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    respond_to do |format|
      format.json {
        product = Product.find(params[:id])      
        if product.update_attributes(params[:product])
          render json: product
        else          
          render json: {:sucess => false, :message => 'Product update error, please contact support'}
        end
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
