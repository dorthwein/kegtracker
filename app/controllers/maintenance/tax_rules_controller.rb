class Maintenance::TaxRulesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /TaxRules
  # GET /TaxRules.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        taxt_rules = JqxConverter.jqxGrid(current_user.entity.TaxRules)
        render json: taxt_rules
      }
    end
  end
  # GET /TaxRules/1
  # GET /TaxRules/1.json
  def show
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = TaxRule.find(params[:id])        
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record  
	
		response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

        render json: response 
      }
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
    # Not Active
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
    taxt_rule = TaxRule.find(params[:id])
    taxt_rule.destroy

    respond_to do |format|    
      format.json { head :no_content }
    end
  end
end



