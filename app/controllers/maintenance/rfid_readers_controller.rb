class Maintenance::RfidReadersController < ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource

  # GET /rfids
  # GET /rfids.json
  def index    
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        rfid_readers = JqxConverter.jqxGrid(RfidReader.all)
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
end
