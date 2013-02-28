class Accounting::InvoicesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /invoices
  # GET /invoices.json
  def index    		
    respond_to do |format|
      format.html # index.html.erb
      format.json {                 
			invoices = JqxConverter.jqxGrid(current_user.entity.invoices)          	            
			print invoices.to_json
          	render json: invoices
      }
    end

  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
    respond_to do |format|
      format.json { 
        invoice = Invoice.find(params[:id])
		invoice_details = invoice.invoice_details       
        location_types = JqxConverter.jqxDropDownList(Location.location_types)

        response = {:location => location, :networks => networks, :location_types => location_types }

        render json: response 
      }
    end
  end

  # GET /invoices/new
  # GET /invoices/new.json
  def new
    respond_to do |format|
      format.json { 
        networks = JqxConverter.jqxDropDownList(current_user.entity.networks)        
        location_types = JqxConverter.jqxDropDownList(Location.location_types)        
        
        response = {:networks => networks, :location_types => location_types }
        render json: response 
      }
    end
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices
  # POST /invoices.json
  def create
    respond_to do |format|          
      format.json { 
        location = Location.new(params[:location])
        
        if location.save
          render json: location
        else
          render json: {:success => false, :message => 'Location creation error, please contact support'}
        end
      }        
    end
  end

  # PUT /invoices/1
  # PUT /invoices/1.json
  def update	
    respond_to do |format|
      format.json {
        location = Location.find(params[:id])
        if location.update_attributes(params[:location])
          render json: location
        else
          render json: {:sucess => false, :message => 'Location update error, please contact support'}
        end
      }
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    location = Location.find(params[:id])
    location.destroy

    respond_to do |format|    
      format.json { head :no_content }
    end
  end
end
