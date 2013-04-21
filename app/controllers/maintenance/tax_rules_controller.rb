class Maintenance::TaxRulesController < ApplicationController
  before_filter :authenticate_user!
  layout "web_app"
  load_and_authorize_resource
  # GET /TaxRules
  # GET /TaxRules.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        taxt_rules = JqxConverter.jqxGrid(current_user.entity.tax_rules.where(record_status: 1))
        render json: taxt_rules
      }
    end
  end
  # GET /TaxRules/1
  # GET /TaxRules/1.json
  def show
    respond_to do |format|
      record = TaxRule.find(params[:id])        
      if can? :update, record 
        format.html {redirect_to :action => 'edit'}
      else             
        format.html {render :layout => 'popup'}
        format.json { 
        
          response = {}
          response[:jqxDropDownLists] = {}        
          response[:record] = record  

    	    response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
          response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

          render json: response 
        }
      end
    end    
  end

  # GET /TaxRules/new
  # GET /TaxRules/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = TaxRule.new
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              

		    response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList([current_user.entity.skus])                            
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

        render json: response 
      }
    end    
  end

  # GET /TaxRules/1/edit
  def edit
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        record = TaxRule.find(params[:id])
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList([current_user.entity.skus])                            
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)
        render json: response 
      }        
    end
  end

  # POST /TaxRules
  # POST /TaxRules.json
  def create
    record = TaxRule.new(params[:record])
    respond_to do |format|
      if record.save
        format.html 
        format.json {  render json: {} }
      else
        format.html { render action: "new" }
        format.json {  render json: {} }
      end
    end
  end

  # PUT /TaxRules/1
  # PUT /TaxRules/1.json
  def update
    record = TaxRule.find(params[:id])
    record.update_attributes(params[:record])
    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /TaxRules/1
  # DELETE /TaxRules/1.json
  def destroy
    record = TaxRule.find(params[:id])
    record.trash
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def restore_multiple
    respond_to do |format|    
      records = TaxRule.where(:id.in => params[:ids])      
      records.restore
      format.json { 
        render json: records
      }
    end
  end

  def delete_multiple
    respond_to do |format|    
      records = TaxRule.where(:id.in => params[:ids])      
      records.trash
      format.json { 
        render json: records
      }
    end
  end
end

















