class Maintenance::BarcodeMakersController < ApplicationController
  before_filter :authenticate_user!
  layout "web_app"
  load_and_authorize_resource

  # load_and_authorize_resource
  # GET /barcode_makers
  # GET /barcode_makers.json
  def index		 
	if params[:file_path]
		@path = params[:file_path]
	end
	respond_to do |format|
		if params[:file_path]
			format.html	
		else
			format.html
		end
	end	
  end
  def download
  	path = params[:file_path]
	respond_to do |format|  
		format.html {send_file(path, :disposition  =>  'inline') }
	end
  end
  
  # GET /barcode_makers/1
  # GET /barcode_makers/1.json  
  def show
    @barcode_maker = BarcodeMaker.find(params[:id])	
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @barcode_maker }
    end
  end

  # GET /barcode_makers/new
  # GET /barcode_makers/new.json
  def new
    @networks = Array.new
    current_user.entity.networks.each do |network|
    	@networks.push([network.description, network._id])
    end
    @barcode_maker = BarcodeMaker.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @barcode_maker }
    end
  end

  # GET /barcode_makers/1/edit
  def edit
    @barcode_maker = BarcodeMaker.find(params[:id])
  end

  # POST /barcode_makers
  # POST /barcode_makers.json
  def create  
    @barcode_maker = BarcodeMaker.new(params[:barcode_maker])	
	@network = Network.find(@barcode_maker.network_id)
	i = @network.tagCounter
	number = params[:barcode_maker][:count].to_i
	last = i + number
	netid = @network.netid

	file_id = (0...8).map{65.+(rand(25)).chr}.join


# CSV TEMPLATE
	if(1 == 0)
		file_path = "public/pdfs/#{file_id}.csv"			
		require 'csv'
		CSV.open(file_path, "w") do |csv|		
			while i < last do 
				i = i + 1
				csv << ["{\"N\":\"#{netid}\",\"V\":\"#{i}\",\"K\":\"#{rand(36**5).to_s(36)}\",\"M\":\"1\"}"]
			end
		end
		@network.tagCounter = i
		@network.save
	end
# END CSV TEMPLATE	
# TAP HANDLE TAGS 
	if(1 == 0)
		Prawn::Document.generate("public/pdfs/#{file_id}.pdf",
									:page_size => [72, 144],
									:page_layout => :landscape,
									:margin => [0,0,0,0]
		)do			
			while i < last do 
				# Row 1		
				i = i + 1			
				key = rand(36**5).to_s(36)				
				bounding_box([5, 73], :width => 72, :height => 72) do
					# GOOGLE CHARTS QR CODE GENERATOR/API LINK

					qr = "http://chart.apis.google.com/chart?cht=qr&chs=72x72&chl=%5B%22T1%22%2C#{i}%2C#{netid}%2C%22#{key}%22%2C%22RF%22%5D&chld=L%7C1"	
					# POST IMAGE TO PDF
					image open(qr), :position => :center, :vposition => :center
				end
				bounding_box([10, 57], :width => 110, :height => 10) do
# %5B%22T1%22%2C#{i}%2C#{netid}%2C%22#{key}%22%5D&chld=L%7C1"	

					txt = "[\"T1\",#{i},#{netid},\"#{key}\",\"TAP\"]"
					text txt, :rotate => 270, :size => 4
#					text txt, :size => 6
				end				


				i = i + 1
				key = rand(36**5).to_s(36)								
				bounding_box([70, 73], :width => 72, :height => 72) do
					# GOOGLE CHARTS QR CODE GENERATOR/API LINK
					qr = "http://chart.apis.google.com/chart?cht=qr&chs=72x72&chl=%5B%22T1%22%2C#{i}%2C#{netid}%2C%22#{key}%22%2C%22RF%22%5D&chld=L%7C1"	
					# POST IMAGE TO PDF
					image open(qr), :position => :center, :vposition => :center
				end
				bounding_box([140, 57], :width => 110, :height => 10) do
# %5B%22T1%22%2C#{i}%2C#{netid}%2C%22#{key}%22%5D&chld=L%7C1"	

					txt = "[\"T1\",#{i},#{netid},\"#{key}\",\"TAP\"]"
					text txt, :rotate => 270, :size => 4
#					text txt, :size => 6
				end				
				start_new_page
			end
		end
		@network.tagCounter = i
		@network.save
		file_path = "public/pdfs/#{file_id}.pdf"
	end
# TAP HANDLE END 	
# WASP TEMPLATE
	if(1 == 1)
		Prawn::Document.generate("public/pdfs/#{file_id}.pdf",
									:page_size => [72, 144],
									:page_layout => :landscape,
									:margin => [0,0,0,0]
		)do			
			while i < last do 
				# Row 1		
				i = i + 1			
				key = rand(36**5).to_s(36)				
				bounding_box([5, 68], :width => 72, :height => 72) do
					# GOOGLE CHARTS QR CODE GENERATOR/API LINK

					qr = "http://chart.apis.google.com/chart?cht=qr&chs=72x72&chl=%5B%22T1%22%2C#{i}%2C#{netid}%2C%22#{key}%22%2C%22RF%22%5D&chld=L%7C1"	
					# POST IMAGE TO PDF
					image open(qr), :position => :center, :vposition => :center
				end
				bounding_box([10, 68], :width => 110, :height => 10) do
# %5B%22T1%22%2C#{i}%2C#{netid}%2C%22#{key}%22%5D&chld=L%7C1"	

					txt = "[\"T1\",#{i},#{netid},\"#{key}\",\"RF\"]"
#					text txt, :rotate => 270, :size => 6
					text txt, :size => 6
				end
				bounding_box([95, 65], :width => 72, :height => 72) do
					txt = 'Near Valve'
					text txt, :rotate => 270
				end
				
				start_new_page
			end
		end
		@network.tagCounter = i
		@network.save
		file_path = "public/pdfs/#{file_id}.pdf"
	end
# END WASP TEMPLATE
# NOLAND 6 TAG LAYOUT PDF		
	if(1 == 0)
		Prawn::Document.generate("public/pdfs/#{file_id}.pdf",
									:page_size => [449.28, 661.392],
									:page_layout => :landscape,
									:margin => [72,72,72,72]
		)do			
			while i < last do 
				# Row 1		
				i = i + 1			
				bounding_box([0, 449.28 - 134.64], :width => 148.464, :height => 134.64) do
					# GOOGLE CHARTS QR CODE GENERATOR/API LINK
					qr = "http://chart.apis.google.com/chart?cht=qr&chs=72x72&chl=%7B%22N%22:%22#{entity_id}%22%2C%22V%22:%22#{i}%22%2C%22K%22:%22#{rand(36**5).to_s(36)}%22%2C%22M%22:%221%22%7D&chld=L%7C1"							
					# POST IMAGE TO PDF
					image open(qr), :position => :center, :vposition => :center
				end
				i = i + 1			
				bounding_box([188.64, 449.28 - 134.64], :width => 148.464, :height => 134.64) do
					# GOOGLE CHARTS QR CODE GENERATOR/API LINK
					qr = "http://chart.apis.google.com/chart?cht=qr&chs=72x72&chl=%7B%22N%22:%22#{entity_id}%22%2C%22V%22:%22#{i}%22%2C%22K%22:%22#{rand(36**5).to_s(36)}%22%2C%22M%22:%221%22%7D&chld=L%7C1"							
					# POST IMAGE TO PDF
					image open(qr), :position => :center, :vposition => :center
				end
				i = i + 1			
				bounding_box([377.28, 449.28 - 134.64], :width => 148.464, :height => 134.64) do
					# GOOGLE CHARTS QR CODE GENERATOR/API LINK
					qr = "http://chart.apis.google.com/chart?cht=qr&chs=72x72&chl=%7B%22N%22:%22#{entity_id}%22%2C%22V%22:%22#{i}%22%2C%22K%22:%22#{rand(36**5).to_s(36)}%22%2C%22M%22:%221%22%7D&chld=L%7C1"							
					# POST IMAGE TO PDF
					image open(qr), :position => :center, :vposition => :center
				end
		
				# Row 2
				i = i + 1			
				bounding_box([0, 449.28 - 305.28], :width => 148.464, :height => 134.64) do
					# GOOGLE CHARTS QR CODE GENERATOR/API LINK
					qr = "http://chart.apis.google.com/chart?cht=qr&chs=72x72&chl=%7B%22N%22:%22#{entity_id}%22%2C%22V%22:%22#{i}%22%2C%22K%22:%22#{rand(36**5).to_s(36)}%22%2C%22M%22:%221%22%7D&chld=L%7C1"							
					# POST IMAGE TO PDF
					image open(qr), :position => :center, :vposition => :center
				end
				i = i + 1			
				bounding_box([188.64, 449.28 - 305.28], :width => 148.464, :height => 134.64) do
					# GOOGLE CHARTS QR CODE GENERATOR/API LINK
					qr = "http://chart.apis.google.com/chart?cht=qr&chs=72x72&chl=%7B%22N%22:%22#{entity_id}%22%2C%22V%22:%22#{i}%22%2C%22K%22:%22#{rand(36**5).to_s(36)}%22%2C%22M%22:%221%22%7D&chld=L%7C1"							
					# POST IMAGE TO PDF
					image open(qr), :position => :center, :vposition => :center
				end
				
				i = i + 1			
				bounding_box([377.28, 449.28 - 305.28], :width => 148.464, :height => 134.64) do
					# GOOGLE CHARTS QR CODE GENERATOR/API LINK
					qr = "http://chart.apis.google.com/chart?cht=qr&chs=72x72&chl=%7B%22N%22:%22#{entity_id}%22%2C%22V%22:%22#{i}%22%2C%22K%22:%22#{rand(36**5).to_s(36)}%22%2C%22M%22:%221%22%7D&chld=L%7C1"							
					# POST IMAGE TO PDF
					image open(qr), :position => :center, :vposition => :center
				end
				start_new_page
			end
		end
		@network.tagCounter = i
		@network.save
		file_path = "public/pdfs/#{file_id}.pdf"
	end
# END NOLAND 6 TAG TEMPLATE

    respond_to do |format|
	    format.html { redirect_to file_path: file_path, notice:  params[:entity_id] }
    #   format.json { render json: @barcode_maker, status: :created, location: @barcode_maker }
    end
    
  end

  # PUT /barcode_makers/1
  # PUT /barcode_makers/1.json
  def update
    @barcode_maker = BarcodeMaker.find(params[:id])

    respond_to do |format|
      if @barcode_maker.update_attributes(params[:barcode_maker])
        format.html { redirect_to @barcode_maker, notice: 'Barcode maker was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @barcode_maker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /barcode_makers/1
  # DELETE /barcode_makers/1.json
  def destroy
    @barcode_maker = BarcodeMaker.find(params[:id])
    @barcode_maker.destroy

    respond_to do |format|
      format.html { redirect_to barcode_makers_url }
      format.json { head :no_content }
    end
  end
end

=begin
class Maintenance::BarcodeMakersController < ApplicationController
  load_and_authorize_resource
  # GET /barcode_makers
  # GET /barcode_makers.json
  def index
    @barcode_makers = BarcodeMaker.all
     	
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @barcode_makers }
    end
  end

  # GET /barcode_makers/1
  # GET /barcode_makers/1.json
  def show
    @barcode_maker = BarcodeMaker.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @barcode_maker }
    end
  end

  # GET /barcode_makers/new
  # GET /barcode_makers/new.json
  def new
    @networks = Array.new
    current_user.entity.networks.each do |network|
    	@networks.push([network.description, network._id])
    end
 
    @barcode_maker = BarcodeMaker.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @barcode_maker }
    end
  end

  # GET /barcode_makers/1/edit
  def edit
    @barcode_maker = BarcodeMaker.find(params[:id])
  end

  # POST /barcode_makers
  # POST /barcode_makers.json
  def create
    @barcode_maker = BarcodeMaker.new(params[:barcode_maker])

    respond_to do |format|
      if @barcode_maker.save
        format.html { redirect_to @barcode_maker, notice: 'Barcode maker was successfully created.' }
        format.json { render json: @barcode_maker, status: :created, location: @barcode_maker }
      else
        format.html { render action: "new" }
        format.json { render json: @barcode_maker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /barcode_makers/1
  # PUT /barcode_makers/1.json
  def update
    @barcode_maker = BarcodeMaker.find(params[:id])

    respond_to do |format|
      if @barcode_maker.update_attributes(params[:barcode_maker])
        format.html { redirect_to @barcode_maker, notice: 'Barcode maker was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @barcode_maker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /barcode_makers/1
  # DELETE /barcode_makers/1.json
  def destroy
    @barcode_maker = BarcodeMaker.find(params[:id])
    @barcode_maker.destroy

    respond_to do |format|
      format.html { redirect_to barcode_makers_url }
      format.json { head :no_content }
    end
  end
end
=end
