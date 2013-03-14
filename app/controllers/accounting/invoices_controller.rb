class Accounting::InvoicesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /Invoices
  # GET /Invoices.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        invoices = JqxConverter.jqxGrid(current_user.entity.invoices)
        render json: invoices
      }
    end
  end
  # GET /Invoices/1
  # GET /Invoices/1.json
  def show
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = Invoice.find(params[:id])        
        response = {}
        response[:jqxDropDownLists] = {}        

        response[:record] = record  
        response[:jqxListBoxes] = {}
        response[:jqxListBoxes][:price_id] = JqxConverter.jqxListBox(current_user.entity.prices)        
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)
        render json: response 
      }
    end    
  end

  # GET /Invoices/new
  # GET /Invoices/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = Invoice.new
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

        render json: response 
      }
    end    
  end


  # GET /Invoices/1/edit
  def edit
    record = Invoice.find(params[:id])
    respond_to do |format|
      if can? :update, record
        format.html {render :layout => 'popup'}
        format.json { 
          response = {}
          response[:jqxDropDownLists] = {}        
          response[:record] = record              


          response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList(current_user.entity.skus)

          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
          response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

          render json: response 
        }        
      else
        format.html {redirect_to :action => 'show'}
      end
    end
  end

  # POST /Invoices
  # POST /Invoices.json
  def create
    record = Invoice.where(entity_id: params[:record][:entity_id], number: params[:record][:number]).first
    if record.nil?
      record = Invoice.new(params[:record])
    end
    respond_to do |format|
      if record.save
        format.html 
        format.json {  render json: record }
      else
        format.html { render action: "new" }
        format.json {  render json: {} }
      end
    end
  end

  # PUT /Invoices/1
  # PUT /Invoices/1.json
  def update
    record = Invoice.find(params[:id])
    print record.to_json
    record.update_attributes(params[:record])    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /Invoices/1
  # DELETE /Invoices/1.json
  def destroy
    record = Invoice.find(params[:id])
    record.destroy

    respond_to do |format|    
      format.json { head :no_content }
    end
  end
end
