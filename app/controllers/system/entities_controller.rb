class System::EntitiesController < ApplicationController
	before_filter :authenticate_user!	
  layout "web_app"
  load_and_authorize_resource

  # GET /entities
  # GET /entities.json
  def index       
    respond_to do |format|
      format.html # index.html.erb
      format.json {        
          if current_user.system_admin == 1     
            render json: JqxConverter.jqxGrid(Entity.all)
          end
      }
    end
  end

  # GET /entities/1
  # GET /entities/1.json
  def show
    respond_to do |format|
      record = Entity.find(params[:id])        
      if can? :update, record 
        format.html {redirect_to :action => 'edit'}
      else           
        format.html {render :layout => 'popup'}      
        format.json {              
          response = {}
          response[:jqxDropDownLists] = {}        
          response[:record] = record              
          render json: response 
        }
      end
    end
  end

  # GET /entities/new
  # GET /entities/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}      
      format.json {          
        
        record = Entity.new
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        render json: response 
      }    
    end
  end

  # GET /entities/1/edit
  def edit
    respond_to do |format|
        format.html {render :layout => 'popup'}
        format.json { 
          record = Entity.find(params[:id])
          response = {}
          response[:jqxDropDownLists] = {}        
          response[:record] = record              
          render json: response 
        }        
    end    
  end

  # POST /entities
  # POST /entities.json
  def create
    record = Entity.new(params[:record])
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

  # PUT /entities/1
  # PUT /entities/1.json
  def update  
    record = Entity.find(params[:id])
    record.update_attributes(params[:record])
    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /entities/1
  # DELETE /entities/1.json
  def destroy
    entity = Entity.find(params[:id])
    entity.destroy
#    entity.mode = 0
 #   entity.save

    respond_to do |format|    
      format.json { head :no_content }
    end
  end

  def distributor_upload
    file = params[:files][0].tempfile
    
    # 0 = FULL, 
    # 1 = DESCRIPTION, 
    # 2 = City,
    # 3 = State,
    CSV.foreach(file) do |row|
        entity = Entity.where(:description => row[1]).first
        print entity.to_s + "fuck"
        if entity.nil?
          # If Nil - Add to DB
          Entity.create(
            :description => row[1],
            :city => row[2],
            :state => row[3],
            :mode => 4
          )          
          print "New Entity \n"
        end
        print row.to_s + "\n"
    end

    respond_to do |format|    
      format.json { 
        render json: {:success => true }
      }
    end  
  end
end

