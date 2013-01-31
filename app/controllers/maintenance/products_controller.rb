class Maintenance::ProductsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /products
  # GET /products.json
  def index
	# Construct Product Array
	# Current User's Entity's Products
#	Need to include partner Products
#    @products = Product.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        if current_user.system_admin == 1 
          products = Product.all
        else
          gatherer = Gatherer.new current_user.entity
          products = gatherer.get_entity_products
        end
        

        response = products.map { |product| { 
                            :entity => product.entity.description, 
                            :description => product.description, 
                            :product_type => product.product_type.description, 
                            :external_id => product.externalID,                       
                            :upc => product.upc,
                            :_id => product._id
                            } 
                          }
        render json: response 
      }
    end
  end
  # GET /products/1
  # GET /products/1.json
  def show
    respond_to do |format|
      if current_user.system_admin == 1
        entities = Entity.all.map{|x| {:html => x.description, :value => x._id}}
      else
      entities = [{:html => current_user.entity.description, :value => current_user.entity._id}]
      end
      product_types = ProductType.all.map{|x| {:html => x.description, :value => x._id}}
      
      product = Product.find(params[:id])
      response = {:product => product, :entities => entities, :product_types => product_types }
      format.json { 
          render json: response 
      }
    end
  end

  # GET /products/new
  # GET /products/new.json
  def new
    respond_to do |format|
      if current_user.system_admin == 1
        entities = Entity.all.map{|x| {:html => x.description, :value => x._id}}
      else
      entities = [{:html => current_user.entity.description, :value => current_user.entity._id}]
      end
      product_types = ProductType.all.map{|x| {:html => x.description, :value => x._id}}
      
      response = {:entities => entities, :product_types => product_types }
      format.json { 
          render json: response 
      }
    end
  end

  # GET /products/1/edit
  def edit
    # Note Active
  end

  # POST /products
  # POST /products.json
  def create
    respond_to do |format|          
      format.json { 
        product = Product.new(params)        
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
        if product.update_attributes(params)
          render json: {:sucess => true}
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
