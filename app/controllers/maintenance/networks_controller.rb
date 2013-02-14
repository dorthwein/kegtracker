class Maintenance::NetworksController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /networks
  # GET /networks.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json {       	
        networks = JqxConverter.jqxGrid(current_user.entity.networks)
        render json: networks                   
      }
    end
  end


  # GET /networks/1
  # GET /networks/1.json
  def show
    network = Network.find(params[:id])	
    entities = JqxConverter.jqxDropDownList([current_user.entity])      
    products = JqxConverter.jqxDropDownList(current_user.entity.production_products) 
    locations = JqxConverter.jqxDropDownList(network.locations) 
    network_types = JqxConverter.jqxDropDownList(Network.network_types)
    
    response = {:network => network, :network_types => network_types, :entities => entities, :products => products, :locations => locations}
    respond_to do |format|
      format.json { render json: response }
    end
  end

  # GET /networks/new
  # GET /networks/new.json
  def new
    entities = JqxConverter.jqxDropDownList([current_user.entity])      
    products = JqxConverter.jqxDropDownList(current_user.entity.production_products)
    network_types = JqxConverter.jqxDropDownList(Network.network_types) 

    response = {:entities => entities, :network_types => network_types, :products => products }
    respond_to do |format|
      format.json { render json: response }
    end
  end

  # GET /networks/1/edit
  def edit
  end


  # POST /networks
  # POST /networks.json
  def create
    respond_to do |format|          
      format.json { 
        network = Network.new(params[:network])        
        if network.save
          render json: network
        else
          render json: {:success => false, :message => 'Network creation error, please contact support'}
        end
      }        
    end
  end

  # PUT /networks/1
  # PUT /networks/1.json
  def update
    respond_to do |format|
      format.json {
        network = Network.find(params[:id])
        if network.update_attributes(params[:network])
          render json: {:sucess => true}
        else
          render json: {:sucess => false, :message => 'Network update error, please contact support'}
        end
      }
    end
  end

  # DELETE /networks/1
  # DELETE /networks/1.json
  def destroy
    network = Network.find(params[:id])
    network.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
