class Maintenance::RfidReadersController < ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource

  # GET /rfids
  # GET /rfids.json
  def index    
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        rfid_readers = RfidReader.all.map { |x| { 
                  :reader_name => x.reader_name,
                  :network => x.network.description,
                  :entity => x.network.entity.description,
                  :antenna_count => x.rfid_antennas.count,
                  :reader_type => x.reader_type,
                  :mac_address => x.mac_address,
                  :last_ip => x.last_ip,
                  :last_read => (x.last_read.nil? ? ' ' : last_read.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y")), 
                  :command_port => x.command_port,
                  :_id => x._id,
                  :network_id => x.network_id
                } 
            }     
        render json: rfid_readers
      }
    end
  end

  def reader_select
    respond_to do |format|
      format.json {
        if current_user.system_admin == 1
          networks = Network.all.map{|x| {:html => x.description, :value => x._id } } 
        else
          networks = current_user.entity.networks.map{|x| {:html => x.description, :value => x._id} } 
        end
     
        antennas = []
        RfidReader.find(params[:_id]).rfid_antennas.each do |x|            
          record = {   
              :html => "<div style='min-width:40%; margin-right:10px; float:left;'> <b> Location Desc: </b> #{x.physical_location} </div> <div style=' float:left;'> <b> Antenna #: </b> #{x.antenna_number} </div>",
              :value => x._id,
            }
            antennas.push(record)
        end

        render json: {:antennas => antennas, :networks => networks}
      }      
    end    
  end

  def reader_delete
    respond_to do |format|
      format.json { 
        rfid_reader = RfidReader.find(params[:_id])
        rfid_reader.rfid_antennas.destroy_all
        rfid_reader.destroy

        render json: {:success => true}
      }      
    end
  end

  def reader_save  
    respond_to do |format|
      format.json { 
        rfid_reader = RfidReader.find(params[:_id])
        rfid_reader.update_attributes(params)        
        render json: {:success => true}
      }
    end
  end

  def reader_new
    respond_to do |format|
      format.json { 

        RfidReader.create(:reader_name => 'New Reader', :network => current_user.entity.networks.first)

        render json: {:success => true}
      }        
    end
  end

  def antennas
      respond_to do |format|        
        format.json { 

          render json: antennas


        }
      end
  end
  def antenna_select 
      respond_to do |format|        
        format.json { 
          antenna = RfidAntenna.find(params[:_id])
          response = {:physical_location => antenna.physical_location, :antenna_number => antenna.antenna_number}
          
          render json: response
        }
      end
  end
  def antenna_save
      respond_to do |format|        
        format.json { 
          rfid_antenna = RfidAntenna.find(params[:_id])
          rfid_antenna.update_attributes!(params)        
          
          antennas = []
          rfid_antenna.rfid_reader.rfid_antennas.each do |x|            
            record = {   
                :html => "<div style='min-width:40%; margin-right:10px; float:left;'> <b> Location Desc: </b> #{x.physical_location} </div> <div style=' float:left;'> <b> Antenna #: </b> #{x.antenna_number} </div>",
                :value => x._id,
              }
              antennas.push(record)
          end

          render json: antennas


        }
      end

  end
  def antenna_new
      respond_to do |format|        
        format.json { 
          rfid_antenna = RfidAntenna.create!(:rfid_reader_id => params[:_id], :physical_location => 'New Antenna')          
          antennas = []

          RfidReader.find(params[:_id]).rfid_antennas.each do |x|            
            record = {   
                :html => "<div style='min-width:40%; margin-right:10px; float:left;'> <b> Location Desc: </b> #{x.physical_location} </div> <div style=' float:left;'> <b> Antenna #: </b> #{x.antenna_number} </div>",
                :value => x._id,
              }
              antennas.push(record)
          end

          render json: antennas
        }
      end
  end

  def antenna_delete
      respond_to do |format|        
        format.json { 

          rfid_reader_id = RfidAntenna.find(params[:_id]).rfid_reader._id
          RfidAntenna.find(params[:_id]).destroy
          antennas = []
          RfidReader.find(rfid_reader_id).rfid_antennas.each do |x|            
            record = {   
                :html => "<div style='min-width:40%; margin-right:10px; float:left;'> <b> Location Desc: </b> #{x.physical_location} </div> <div style=' float:left;'> <b> Antenna #: </b> #{x.antenna_number} </div>",
                :value => x._id,
              }
              antennas.push(record)
          end
          

          render json: antennas
        }
      end
  end

  # GET /rfids/new
  # GET /rfids/new.json
=begin  
  def new
    @rfid_reader = RfidReader.new
	if current_user.system_admin == 1
		@networks = Network.all.map { |network| [network.description, network.id] }
	else
		@networks = current_user.entity.networks.map { |network| [network.description, network.id] }
	end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rfid_reader }
    end
  end

  # GET /rfids/1/edit

  def edit  
    @rfid_reader = RfidReader.find(params[:id])
	@networks = current_user.entity.networks.map { |network| [network.description, network.id] } 
 end

  # POST /rfids
  # POST /rfids.json
  def create
	params[:rfid_reader][:mac_address] = "#{params[:rfid_reader][:mac_address_1]}:#{params[:rfid_reader][:mac_address_2]}:#{params[:rfid_reader][:mac_address_3]}:#{params[:rfid_reader][:mac_address_4]}:#{params[:rfid_reader][:mac_address_5]}:#{params[:rfid_reader][:mac_address_6]}"  
    @rfid_reader = RfidReader.new(params[:rfid_reader])
	i = 0
	while i < params[:antenna_count].to_i
		i = i + 1	
	    rfid_antenna = RfidAntenna.create(:antenna_number => i - 1, :rfid_reader => @rfid_reader)
	end
	
    respond_to do |format|
      if @rfid_reader.save
        format.html { redirect_to [:maintenance, @rfid_reader], notice: 'Rfid was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /rfids/1
  # PUT /rfids/1.json
  def update
    @rfid_reader = RfidReader.find(params[:id])
	params[:rfid_reader][:mac_address] = "#{params[:rfid_reader][:mac_address_1]}:#{params[:rfid_reader][:mac_address_2]}:#{params[:rfid_reader][:mac_address_3]}:#{params[:rfid_reader][:mac_address_4]}:#{params[:rfid_reader][:mac_address_5]}:#{params[:rfid_reader][:mac_address_6]}"
	i = @rfid_reader.rfid_antennas.count
	if params[:antenna_count].to_i > i
		#Add Antennas until i == target
		until i == params[:antenna_count].to_i
			RfidAntenna.create(:antenna_number => i, :rfid_reader => @rfid_reader)
			i = i + 1				
			print i
		end		
	end
	if params[:antenna_count].to_i < i
		# Remove Antennas until i == target
		until i == params[:antenna_count].to_i
			print @rfid_reader.rfid_antennas.where(:antenna_number => i - 1).first.destroy
			i = i - 1				
		end
	end	
    respond_to do |format|    
      if @rfid_reader.update_attributes(params[:rfid_reader])
        format.html { redirect_to [:maintenance, @rfid_reader], notice: 'Rfid was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /rfids/1
  # DELETE /rfids/1.json
  def destroy
    @rfid_reader = RfidReader.find(params[:id])
    @rfid_reader.destroy

    respond_to do |format|
      format.html { redirect_to rfids_url }
      format.json { head :no_content }
    end
  end
  def read
  	  
  	
  end
=end
end
