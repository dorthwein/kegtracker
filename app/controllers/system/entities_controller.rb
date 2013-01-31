class System::EntitiesController < System::ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource

  # GET /entity
  # GET /entity.json
  def index
    @entity = Entity.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @entity }
    end
  end

  # GET /entity/1
  # GET /entity/1.json
  def show
    @entity = Entity.find(params[:id])
    @products = @entity.products
    @users = @entity.users
    @networks = @entity.networks
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @entity }
    end
  end

  # GET /entity/new
  # GET /entity/new.json
  def new
    @entity = Entity.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /entity/1/edit
  def edit
    @entity = Entity.find(params[:id])
  end

  # POST /entity
  # POST /entity.json
  def create
    @entity = Entity.new(params[:entity])
#	@user = User.new(:email => 'test@example.com', :password => 'password', :password_confirmation => 'password')
	print "#{params[:user]} <-- Mark"
	@user = User.new(:email => params[:user][:email], :password =>  params[:user][:password], :password_confirmation => params[:user][:password_confirmation], :entity => @entity)
	@network = Network.new(:entity => @entity, :description => @entity.description)
=begin
					:user_maintenance => 1,
					:location_maintenance => 1,
					:product_maintenance => 1,
					:production_maintenance => 1,
					:network_membership_maintenance => 1,
					:barcode_maker_maintenance => 1
=end

    respond_to do |format|
      if @user.save && @entity.save && @network.save
        format.html { redirect_to system_entities_path, notice: 'Entity type was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /entity/1
  # PUT /entity/1.json
  def update
    @entity = Entity.find(params[:id])

    respond_to do |format|
      if @entity.update_attributes(params[:entity])
        format.html { redirect_to [:system, @entity], notice: 'Entity type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @entity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entity/1
  # DELETE /entity/1.json
  def destroy
    @entity = Entity.find(params[:id])
    @entity.destroy

    respond_to do |format|
      format.html { redirect_to system_entities_path }
      format.json { head :no_content }
    end
  end
end
