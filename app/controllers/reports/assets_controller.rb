class Reports::AssetsController < ApplicationController	
	before_filter :authenticate_user!	
	layout "web_app"
#	load_and_authorize_resource
# **********************************
# Asset Reports
# **********************************
	def index    

		respond_to do |format|		
		  	format.html # index.html.erb
		  	format.json { 		  								  		
				render json: JqxConverter.jqxGrid(current_user.entity.visible_assets)
			}
		end
	end  
  	def show
	    respond_to do |format|
	      format.html {render :layout => 'popup'}
	      format.json { 
	        
	      record = Asset.find(params[:id])        
	      response = {}
	      response[:jqxDropDownLists] = {}            
	      response[:jqxRecordLinkButton] = {}
	      
	      response[:record] = record  
	      if !record.invoice.nil?
	      	response[:record][:invoice_date] = record.invoice.date
	      else
	      	response[:record][:invoice_date] = nil				   
	      end
			response[:jqxRecordLinkButton][:asset_cycle_fact_id] = JqxConverter.jqxRecordLinkButton(record.asset_cycle_fact_id)
			response[:jqxDropDownLists][:product_id] = JqxConverter.jqxDropDownList([record.product])
			response[:jqxDropDownLists][:product_entity_id] = JqxConverter.jqxDropDownList([record.product.entity])
			response[:jqxDropDownLists][:asset_type_id] = JqxConverter.jqxDropDownList([record.asset_type])
			response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([record.entity])

#	        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

	        render json: response 
	      }
	    end    
  	end

  # GET /Assets/new
  # GET /Assets/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = Asset.new
        response = {}
        response[:jqxDropDownLists] = {}   
        response[:record] = record              

		response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList(current_user.entity.skus)
        response[:jqxDropDownLists][:base_Asset_tier] = JqxConverter.jqxDropDownList(Asset.base_Asset_tiers)
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
#        response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

        render json: response 
      }
    end    
  end

  # GET /Assets/1/edit
  def edit
    record = Asset.find(params[:id])
    respond_to do |format|
      if  1 == 0 # can? :update, record
        format.html {render :layout => 'popup'}
        format.json { 
          response = {}
          response[:jqxDropDownLists] = {}                  
          response[:record] = record 

          response[:jqxDropDownLists][:sku_id] = JqxConverter.jqxDropDownList(current_user.entity.skus)                                        
          response[:jqxDropDownLists][:base_Asset_tier] = JqxConverter.jqxDropDownList(Asset.base_Asset_tiers)
          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        
#          response[:jqxDropDownLists][:bill_to_entity_id] = JqxConverter.jqxDropDownList(current_user.entity.related_entities)

          render json: response 
        }        
      else
        format.html {redirect_to :action => 'show'}
      end
    end
  end

  # POST /Assets
  # POST /Assets.json
  def create
    record = Asset.new(params[:record])
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

  # PUT /Assets/1
  # PUT /Assets/1.json
  def update
    record = Asset.find(params[:id])
    record.update_attributes(params[:record])
    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /Assets/1
  # DELETE /Assets/1.json
  def destroy
    record = Asset.find(params[:id])
    record.destroy

    respond_to do |format|    
      format.json { head :no_content }
    end
  end


=begin
	def browse_row_select
		respond_to do |format|
			format.json {
				response = []				
				asset = Asset.find(params[:_id]);
				current_user.entity.visible_asset_cycle_facts.where(asset: asset).each do |x|

					date = 	"<td class='life_cycle_select'><b> Start Date: </b> #{x.start_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y") rescue nil} </td>"
					product = 	"<td class='life_cycle_select'> <b> Product: </b> #{x.product.description} </td>"
					brewery = 	"<td class='life_cycle_select'> <b> Brewery: </b> #{x.product.entity.description} </td>"
					location_network = 	"<td class='life_cycle_select'> <b> Start Network: </b> #{x.start_network.description} </td>"
					
					asset_cycle_fact = x._id
					response.push({:value => asset_cycle_fact, :html => '<table><tbody><tr>' + date + location_network +  '</tr> <tr>' + product + brewery + '</tr></tbody> </table>'})
				end

				render json: response
			}
		end
	end
	def browse_life_cycle_select
		respond_to do |format|
			format.json {
#				gatherer = Gatherer.new(current_user.entity)
#				location, product, entity = gatherer.asset_activity_fact_criteria				
				transactions = 'No Fill Event Found' 
				response = {}
				
				asset_cycle_fact = AssetCycleFact.find(params[:record])				
				if !asset_cycle_fact.nil?
		            x_product = 	"<td> <b> 	Product: 	</b> 	#{asset_cycle_fact.product.description}	 </td>"
		            x_brewery = 	"<td> <b> 	Brewery: 	</b> 	#{asset_cycle_fact.product.entity.description} </td>"
		            x_asset_type = 	"<td> <b> 	Asset Type: </b> 	#{asset_cycle_fact.asset_type.description} </td>"
		            x_entity = 		"<td> <b> 	Owner: 		</b> 	#{asset_cycle_fact.entity.description} </td>"
		            x_fill_date = 	"<td> <b> 	Start Date: 	</b> 	#{asset_cycle_fact.start_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y")} </td>"
					x_fill_count = 	"<td> <b> 	Fill Count: </b> 	#{asset_cycle_fact.fill_count} 		</td>"
					x_tag_value = 	"<td> <b> 	Tag Value: 	</b> 	#{asset_cycle_fact.asset.tag_value} 	</td>"
					x_tag_key = 	"<td> <b> 	Tag Key: 	</b> 	#{asset_cycle_fact.asset.tag_key} 		</td>"

					# Start Table
					transactions = "<table> <tbody> " 

					# Add Asset Details
					transactions = transactions + "<tr>" + x_product + x_brewery + x_asset_type + x_entity + x_fill_date + " </tr> "
					transactions = transactions + "<tr>" + x_fill_count + x_tag_value + x_tag_key + "<td></td><td></td> </tr> "
					# Activity Header
					transactions = transactions + ' <tr> <td colspan="5"> <h3 style="border-bottom:1px solid #CCC;border-top:1px solid #CCC; margin:10px 0 0 0;"> Activity </h3> </td> </tr>'


					
					transactions = transactions + '<tr>	<th> Action	</th> <th> Location </th> <th> Location Network	</th> <th> Date </th> <th> Transaction Entity </th> </tr>'


					# For each transaction, create a row
					asset_activity_facts = current_user.entity.visible_asset_activity_facts.where(asset_cycle_fact: asset_cycle_fact)					
					print asset_activity_facts.to_json
					asset_activity_facts.each do |x|					
						action = 					"<td> #{x.handle_code_description} </td>"
						location = 					"<td> #{x.location.description} </td>"
						location_network = 			"<td> #{x.location.network_description} </td>"
						date = 						"<td> #{x.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y")} </td>"
						transaction_entity = 		"<td> #{x.user.entity.description} </td>"
						transactions = transactions + '<tr>' + action + location + location_network + date + transaction_entity +  '</tr>'
					end
				end
				response = {:html => transactions}
				render json: response
			}
		end
	end

	def sku_summary_report_advanced
		respond_to do |format|  
			format.html
		    format.json {
		    	if params['date'].nil?
		    		start_date = Time.new() - (14 * 86400)
		    		end_date = Time.new()
		    	else
		    		start_date = DateTime.parse(params['date']['0'])
		    		end_date = DateTime.parse(params['date']['1'])
		    	end
				
				asset_summary_facts = AssetSummaryFact.where(:report_entity => current_user.entity).between(fact_time: start_date..end_date).desc(:fact_time)
				response = asset_summary_facts

		    	render json: response
			}			
		end			
	end
=end
	def sku_summary_report_simple
		respond_to do |format|  
			format.html
		    format.json {
				
				date = DateTime.parse(params['date'])

    			start_date = date.beginning_of_day
    			end_date = date.end_of_day
    			
#				if params['location_network_id'].nil?
#					default_network = visible_networks[0]
#				else
#					default_network = Network.find(params['location_network_id'])
#				end				
								
				facts = JqxConverter.jqxGrid(current_user.entity.network_facts.between(fact_time: start_date..end_date))
		    	response = {:grid => facts} #, :location_networks => location_network_list}
 	 
		    render json: response
		}
		end			
	end	
end

