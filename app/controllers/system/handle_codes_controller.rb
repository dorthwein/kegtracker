class System::HandleCodesController < System::ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource

  # GET /handle_codes
  # GET /handle_codes.json
  def index
    @handle_codes = HandleCode.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @handle_codes }
    end
  end

  # GET /handle_codes/1
  # GET /handle_codes/1.json
  def show
    @handle_code = HandleCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @handle_code }
    end
  end

  # GET /handle_codes/new
  # GET /handle_codes/new.json
  def new
    @handle_code = HandleCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @handle_code }
    end
  end

  # GET /handle_codes/1/edit
  def edit
    @handle_code = HandleCode.find(params[:id])
  end

  # POST /handle_codes
  # POST /handle_codes.json
  def create
    @handle_code = HandleCode.new(params[:handle_code])

    respond_to do |format|
      if @handle_code.save
        format.html { redirect_to system_handle_codes_path, notice: 'Handle code was successfully created.' }
        format.json { render json: @handle_code, status: :created, location: @handle_code }
      else
        format.html { render action: "new" }
        format.json { render json: @handle_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /handle_codes/1
  # PUT /handle_codes/1.json
  def update
    @handle_code = HandleCode.find(params[:id])

    respond_to do |format|
      if @handle_code.update_attributes(params[:handle_code])
        format.html { redirect_to system_handle_codes_path, notice: 'Handle code was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @handle_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /handle_codes/1
  # DELETE /handle_codes/1.json
  def destroy
    @handle_code = HandleCode.find(params[:id])
    @handle_code.destroy

    respond_to do |format|
      format.html { redirect_to handle_codes_url }
      format.json { head :no_content }
    end
  end
end
