class Accounting::InvoiceLineItemsController < ApplicationController
  before_filter :authenticate_user!
  layout "web_app"
  load_and_authorize_resource
  # GET /Invoices
  # GET /Invoices.json  
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        invoice = Invoice.find(params[:invoice_id])
        records = JqxConverter.jqxGrid(invoice.invoice_line_items)
        render json: records
      }
    end
  end

  # GET /Invoices/1
  # GET /Invoices/1.json
  def show
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = InvoiceLineItem.find(params[:id])        
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record

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
       	 
        record = InvoiceLineItem.new
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
    record = InvoiceLineItem.find(params[:id])
    respond_to do |format|
      if can? :update, record
        format.html {render :layout => 'popup'}
        format.json { 
          response = {}
          response[:jqxDropDownLists] = {}        
          response[:record] = record              


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
    params[:record][:invoice_id] = params[:invoice_id]
    invoice = Invoice.find(params[:invoice_id])
    record = InvoiceLineItem.where(invoice: invoice).find_or_create_by(sku: params[:record][:sku_id])    
    record.quantity = params[:record][:quantity]


    respond_to do |format|
      if record.save
        format.html 
        format.json {  render json: record }
      else
        format.html { render action: "new" }
        format.json {  render json: {alert: 'failed'} }
      end
    end
  end

  # PUT /Invoices/1
  # PUT /Invoices/1.json
  def update
    record = InvoiceLineItem.find(params[:id])
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
    record = InvoiceLineItem.find(params[:id])
    record.destroy

    respond_to do |format|    
      format.json { head :no_content }
    end
  end
end
