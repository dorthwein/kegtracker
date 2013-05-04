class Accounting::InvoicesController < ApplicationController
  before_filter :authenticate_user!
 
  load_and_authorize_resource
  # GET /Invoices
  # GET /Invoices.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        @records = JqxConverter.jqxGrid(current_user.entity.invoices.where(record_status: 1).map{|x| {
          a: x.bill_to_entity_description,
          b: x.invoice_number,
          c: x.date != nil ? x.date.to_i * 1000 : nil,          
          _id: x._id,
        }})
        render json: @records        
      }
    end
  end
  # GET /Invoices/1
  # GET /Invoices/1.json
  def show
    @record = Invoice.find(params[:id]) 
    @prices = current_user.entity.prices
    @entities = [current_user.entity]
    @bill_to_entities = current_user.entity.related_entities

    respond_to do |format|
      if can? :update, @record
        format.html {redirect_to :action => 'edit'}
      else

        format.html {render :layout => 'popup'}
        format.json { 
          response = {}
          render json: response 
        }
      end    
    end
  end

  # GET /Invoices/new
  # GET /Invoices/new.json
  def new
    @record = Invoice.new
    @prices = current_user.entity.prices
    @entities = [current_user.entity]
    @bill_to_entities = current_user.entity.related_entities
    @skus = Sku.where(:product_id.in => current_user.entity.production_products.map{|x| x._id})
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json {         
        response = {}        
        render json: response 
      }
    end
  end


  # GET /Invoices/1/edit
  def edit
    @record = Invoice.find(params[:id]) 
    @prices = current_user.entity.prices
    @entities = [current_user.entity]
    @bill_to_entities = current_user.entity.related_entities
    @skus = Sku.where(:product_id.in => current_user.entity.production_products.map{|x| x._id})
    respond_to do |format|      


      format.html {render :layout => 'popup'}
      format.json { 
        response = {}
        render json: response 
      }        
    end
  end

  # POST /Invoices
  # POST /Invoices.json
  def create    
    @record = Invoice.find_or_create_by(:entity_id => current_user.entity_id, invoice_number: params[:invoice][:invoice_number])
    respond_to do |format|
      params[:invoice][:record_status] = 1
      if @record.update_attributes(params[:invoice])
        format.html { head :no_content }
        format.json {  render json: @record }
      end
    end
  end

  # PUT /Invoices/1
  # PUT /Invoices/1.json
  def update
    @record = Invoice.find(params[:id])    
    @record.update_attributes(params[:invoice])    

    respond_to do |format|      
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /Invoices/1
  # DELETE /Invoices/1.json
  def destroy
    @record = Invoice.find(params[:id])
    @record.trash

    respond_to do |format|    
      format.json { head :no_content }
    end
  end

  def restore_multiple
    respond_to do |format|    
      @records = Network.where(:id.in => params[:ids])      
      @records.restore
      format.json { 
        render json: @records
      }
    end
  end
  def delete_multiple
    respond_to do |format|    
      @records = Invoice.where(:id.in => params[:ids])      
      @records.trash
      format.json { 
        render json: @records
      }
    end
  end
end


















