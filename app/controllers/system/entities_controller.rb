class System::EntitiesController < System::ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource
  layout "web_app"

  # GET /entities
  # GET /entities.json

  def index       
    respond_to do |format|
      format.html # index.html.erb
      format.json {        
          if current_user.system_admin == 1     
            JqxConverter.jqxGrid(Entity.all)
            render json: JqxConverter.jqxGrid(Entity.all)
          end
      }
    end

  end

  # GET /entities/1
  # GET /entities/1.json
  def show
    respond_to do |format|
      format.json { 
        entity = Entity.find(params[:id])
        users = entity.users.map{|x| {:html => x.email, :value => x._id}}
        

        response = {:entity => entity, :users => users}
        render json: response 
      }
    end
  end

  # GET /entities/new
  # GET /entities/new.json
  def new
    respond_to do |format|
      format.json { 
        users = JqxConverter.jqxDropDownList(entity.users)

        response = {:users => users}
        render json: response 
      }
    end
  end

  # GET /entities/1/edit
  def edit
  end

  # POST /entities
  # POST /entities.json
  def create
    respond_to do |format|          
      format.json { 
        entity = Entity.new(params[:entity])
        
        if entity.save
          render json: entity
        else
          render json: {:success => false, :message => 'Entity creation error, please contact support'}
        end
      }        
    end
  end

  # PUT /entities/1
  # PUT /entities/1.json
  def update  
    respond_to do |format|
      format.json {
        entity = Entity.find(params[:id])
        if entity.update_attributes(params[:entity])
          render json: entity
        else
          render json: {:sucess => false, :message => 'Location update error, please contact support'}
        end
      }
    end
  end

  # DELETE /entities/1
  # DELETE /entities/1.json
  def destroy
    entity = Entity.find(params[:id])
    entity.mode = 0
    entity.save

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

