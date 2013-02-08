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
        
      	response = networks.map { |network| {	
      							:netid => network.netid,	
      							:description => network.description, 
      							:entity => network.entity.description, 							
                    :network_type_description => network.network_type_description,

                    :smart_mode_product_description => network.smart_mode_product_description,
                    :smart_mode_in_location_description => network.smart_mode_in_location_description,
                    :smart_mode_out_location_description => network.smart_mode_out_location_description,

                    :auto_mode => network.auto_mode,
      							:_id => network._id
      							} 
      						}
          render json: response                   
      }
    end
  end


  # GET /networks/1
  # GET /networks/1.json
  def show
    network = Network.find(params[:id])	
    if current_user.system_admin == 1
      entities = Entity.all.map{|x| {:html => x.description, :value => x._id}}
      products = Product.all.map{|x| {:html => x.description + " (#{x.entity.description})", :value => x._id}}    
    else
      entities = [{:html => current_user.entity.description, :value => current_user.entity._id }] #current_user.entity.map{|x| { :html => x.description, :value => x._id }}
      products = current_user.entity.products.map{|x| {:html => x.description + " (#{x.entity.description})", :value => x._id}}      
    end
    locations = network.locations.map{|x| {:html => x.description, :value => x._id}}
    network_types = Network.network_types.map{|x| {:html => x[:description], :value => x[:_id]}}        
    
    response = {:network => network, :network_types => network_types, :entities => entities, :products => products, :locations => locations}
    respond_to do |format|
      format.json { render json: response }
    end
  end

  # GET /networks/new
  # GET /networks/new.json
  def new
    if current_user.system_admin == 1
      entities = Entity.all.map{|x| {:html => x.description, :value => x._id}}
      products = Product.all.map{|x| {:html => x.description + " (#{x.entity.description})", :value => x._id}}
    else
      entities = [{:html => current_user.entity.description, :value => current_user.entity._id }] #current_user.entity.map{|x| { :html => x.description, :value => x._id }}
      products = current_user.entity.products.map{|x| {:html => x.description + " (#{x.entity.description})", :value => x._id}}
    end  
    locations = []
    current_user.entity.networks.each do |y|
      locations = locations + y.locations.map{|x| {:html => x.description, :value => x._id}}    
    end
network_types = Network.network_types.map{|x| {:html => x[:description], :value => x[:_id]}}        

    response = {:entities => entities, :network_types => network_types, :products => products, :locations => locations }
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
        network = Network.new(params)
        
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
        if network.update_attributes(params)
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
