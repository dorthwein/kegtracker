class Maintenance::NetworksController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /networks
  # GET /networks.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
      	
        if current_user.system_admin == 1
          networks = Network.all
        else
          gatherer = Gatherer.new current_user.entity
          networks = gatherer.get_networks
        end
    
        response = JqxConverter.jqxGrid(networks)
        render json: response                   
      }
    end
  end


  # GET /networks/1
  # GET /networks/1.json
  def show
    network = Network.find(params[:id])	
    if current_user.system_admin == 1
      entities = JqxConverter.jqxDropDownList(Entity.all) #.map{|x| {:html => x.description, :value => x._id}}
      products = JqxConverter.jqxDropDownList(Product.all) # .map{|x| {:html => x.description + " (#{x.entity.description})", :value => x._id}}    
    else
      entities = [{:html => current_user.entity.description, :value => current_user.entity._id }] #current_user.entity.map{|x| { :html => x.description, :value => x._id }}
      products = JqxConverter.jqxDropDownList(current_user.entity.products) #.map{|x| {:html => x.description + " (#{x.entity.description})", :value => x._id}}      
    end
    locations = JqxConverter.jqxDropDownList(network.locations) #.map{|x| {:html => x.description, :value => x._id}}
    network_types = JqxConverter.jqxDropDownList(Network.network_types) #.map{|x| {:html => x[:description], :value => x[:_id]}}        
    
    response = {:network => network, :network_types => network_types, :entities => entities, :products => products, :locations => locations}
    respond_to do |format|
      format.json { render json: response }
    end
  end

  # GET /networks/new
  # GET /networks/new.json
  def new
    if current_user.system_admin == 1
      entities = JqxConverter.jqxDropDownList(Entity.all) #.map{|x| {:html => x.description, :value => x._id}}
      products = JqxConverter.jqxDropDownList(Product.all) # .map{|x| {:html => x.description + " (#{x.entity.description})", :value => x._id}}    
    else
      entities = [{:html => current_user.entity.description, :value => current_user.entity._id }] #current_user.entity.map{|x| { :html => x.description, :value => x._id }}
      products = JqxConverter.jqxDropDownList(current_user.entity.products) #.map{|x| {:html => x.description + " (#{x.entity.description})", :value => x._id}}      
    end
    network_types = JqxConverter.jqxDropDownList(Network.network_types) #.map{|x| {:html => x[:description], :value => x[:_id]}}        

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
