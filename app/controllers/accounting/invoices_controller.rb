class Accounting::InvoicesController < ApplicationController
  before_filter :authenticate_user!
  layout "web_app"
  load_and_authorize_resource
  # GET /Invoices
  # GET /Invoices.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        records = JqxConverter.jqxGrid(current_user.entity.invoices.map{|x| {
          a: x.bill_to_entity_description,
          b: x.invoice_number,
          c: x.date != nil ? x.date.to_i * 1000 : nil,          
          d: x._id,
        }})
        render json: records        
      }
    end
  end
  # GET /Invoices/1
  # GET /Invoices/1.json
  def show
    respond_to do |format|
      record = Invoice.find(params[:id]) 
      if can? :update, record 
        format.html {redirect_to :action => 'edit'}
      else       

        format.html {render :layout => 'popup'}
        format.json { 
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
    respond_to do |format|

      format.html {render :layout => 'popup'}
      format.json { 
        record = Invoice.find(params[:id])
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList(current_user.entity.skus)
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)
        render json: response 
      }        
    end
  end

  # POST /Invoices
  # POST /Invoices.json
  def create
    record = Invoice.where(entity_id: params[:record][:entity_id], invoice_number: params[:record][:invoice_number]).first
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
