class AssetActivityFact
  include Mongoid::Document
  include Mongoid::Timestamps  	
  field :record_status, type: Integer, default: 1

# Created in Scan Object
# Used by report builder to generate report facts

# Fact Details 
  field :fact_time, :type => Time

  has_one :invoice_attached_asset

  belongs_to :location

# Field :handle_code_description, type: String
  field :location_description, type: String
  field :location_network_description, type: String
  field :location_type, type: Integer

# Asset Details
  belongs_to :asset
  field :batch_number, type: String

  belongs_to :entity      # Asset Owner
  belongs_to :product
  belongs_to :asset_type
  belongs_to :sku
  
#  belongs_to :asset_cycle_fact, inverse_of: 'AssetCycleFact'
  belongs_to :prev_asset_activity_fact, :class_name => 'AssetActivityFact', :inverse_of => 'AssetActivityFact'
  belongs_to :next_asset_activity_fact, :class_name => 'AssetActivityFact', :inverse_of => 'AssetActivityFact'

  field :next_asset_activity_fact_time, type: Time
  field :days_at_location, type: Integer

  belongs_to :location_entity,  :class_name => 'Entity'
  field :location_entity_description, type: String
  
  field :location_entity_arrival_time, type: Time
  field :location_entity_departure_time, type: Time

# Variable Details 
  field :fill_count, type: Integer
  field :asset_status, type: Integer, :default => 0  
  field :location_network_type, type: Integer

  belongs_to :location_network, :class_name => 'Network'  
  belongs_to :user  

# Reporting
  def get_asset_status_description
    case self.asset_status.to_i
    when 0
      return 'Empty'  
    when 1
      return 'Full' 
    when 2
      return 'Market' 
    when 3
      return 'Damaged'  
    when 4
      return 'Lost' 
    else
      return 'Unknown' 
    end
  end

  def self.create_from_asset asset
    details = {
      :asset_id => asset._id,
      :asset_status => asset.asset_status,
      :asset_type_id => asset.asset_type_id,                                   
      :entity_id => asset.entity_id,
      :product_id => asset.product_id,
      :fact_time => asset.last_action_time,

      :location_id => asset.location_id,
      :location_network_id => asset.location_network_id,
      :user_id => asset.user_id,
      :batch_number => asset.batch_number
    }
    AssetActivityFact.create(details)
  end

	# Temp migration file etc...
=begin
  def sync_to_asset_cycle_fact
      cycle_fact = AssetCycleFact.where(fill_asset_activity_fact: self.fill_asset_activity_fact).first_or_create!
      self.asset_cycle_fact_id = cycle_fact._id
  
      cycle_fact.entity_id = self.entity_id
      cycle_fact.product_id = self.product_id
      cycle_fact.asset_type_id = self.asset_type_id
      cycle_fact.asset_id = self.asset_id      

      if !self.fill_asset_activity_fact.nil?
        cycle_fact.fill_time = self.fill_asset_activity_fact.fact_time # rescue nil
        cycle_fact.fill_asset_activity_fact_id = self.fill_asset_activity_fact_id    
        cycle_fact.fill_network_id = self.fill_asset_activity_fact.location_network_id # rescue nil    


        cycle_fact.start_time = self.fill_asset_activity_fact.fact_time # rescue nil
        cycle_fact.start_asset_activity_fact_id = self.fill_asset_activity_fact_id    
        cycle_fact.start_network_id = self.fill_asset_activity_fact.location_network_id # rescue nil    
      end

      if !self.delivery_asset_activity_fact.nil?
        cycle_fact.delivery_time = self.delivery_asset_activity_fact.fact_time  # rescue nil
        cycle_fact.delivery_asset_activity_fact_id = self.delivery_asset_activity_fact_id
        cycle_fact.delivery_network_id = self.delivery_asset_activity_fact.location_network_id #rescue nil
      end
      if !pickup_asset_activity_fact.nil?
        cycle_fact.pickup_time = self.pickup_asset_activity_fact.fact_time # rescue nil
        cycle_fact.pickup_asset_activity_fact_id = self.pickup_asset_activity_fact_id  
        cycle_fact.pickup_network_id = self.pickup_asset_activity_fact.location_network_id  # rescue nil  
      end
    

      next_fill = AssetActivityFact.where(asset: self.asset, handle_code: 4).gt( fact_time: self.fact_time).asc.first
      
      if !next_fill.nil?
        cycle_fact.end_time = next_fill.fact_time
        cycle_fact.cycle_complete = 1
        cycle_fact.end_network_id = next_fill.location_network_id
        cycle_fact.end_asset_activity_fact_id    =   next_fill._id
        print " ----- Cycle Completed \n"
      end

      cycle_fact.fill_count = self.fill_count
          

      cycle_fact.save!      
      self.save!
  end
=end
  def set_asset_status
    unless self.location.nil?
      case self.location.location_type 
      when 1
        self.asset_status = 1
      when 2
        self.asset_status = 0
      when 3
        self.asset_status = 2
      end 
    else 
#      self.destroy
    end
  end


  def trash
    self.update_attributes(record_status: 0)
  end
  
  def restore
    self.update_attributes(record_status: 1)
  end

  before_destroy :removal
  def removal
    if self.asset.asset_activity_fact == self
      # Find current asset and revert back to previous fact
      asset_rollback = {
        :asset_activity_fact => (self.prev_asset_activity_fact rescue nil),
        :asset_type => (self.prev_asset_activity_fact.asset_type rescue nil),
        :product => (self.prev_asset_activity_fact.product rescue nil),

 
        :location => (self.prev_asset_activity_fact.location rescue nil),
        :user => (self.prev_asset_activity_fact.user rescue nil),
        :last_action_time => (self.prev_asset_activity_fact.fact_time rescue nil),
        :batch_number => (self.prev_asset_activity_fact.batch_number rescue nil),

      }
      self.asset.update_attributes(asset_rollback)              
    end

    # Find items attached to an invoice and remove it
    self.invoice_attached_asset.delete rescue nil
    print 'Asset Rollback'
  end

  before_save :sync
	def sync	    
    self.location_network = self.location.network
    self.location_entity = self.location.entity
    self.location_network_type = self.location_network.network_type rescue nil
    self.prev_asset_activity_fact_id = AssetActivityFact.where(:asset => self.asset).lt(fact_time: self.fact_time).desc(:fact_time).first._id
    self.next_asset_activity_fact_id = AssetActivityFact.where(:asset => self.asset).gt(fact_time: self.fact_time).asc(:fact_time).first._id

    
    self.next_asset_activity_fact.nil? ? nil :  self.next_asset_activity_fact_time = self.next_asset_activity_fact.fact_time 


    self.sku = Sku.find_or_create_by(entity: self.product.entity, primary_asset_type: self.asset_type, product: self.product)
#    self.handle_code_description = self.get_handle_code_description
    self.location_description = self.location.description
    self.location_network_description = self.location_network.description    
    self.location_entity_description = self.location_entity.description 
    
    self.set_asset_status
    if self.asset_status.to_i == 0
      self.product = nil
      self.batch_number = nil
    end
#    self.product_description = self.asset_status.to_i == 0 ? 'Empty' : self.product.description
#    self.product_entity_description = self.asset_status.to_i == 0 ? 'Empty' : self.product_entity.description


    # If different entity - Update possession_time
    if self.next_asset_activity_fact
      # Moved From Location
      days = ((self.next_asset_activity_fact.fact_time.to_i - self.fact_time.to_i)/86400).to_i
      self.days_at_location = days  
      # Entity Change hands
      if self.location_entity_id != self.next_asset_activity_fact.location_entity_id
        self.location_entity_departure_time = self.fact_time        

      else
        self.location_entity_departure_time = nil

      end
    end
    
    if self.prev_asset_activity_fact
      if self.location_entity_id != self.prev_asset_activity_fact.location_entity_id
        self.location_entity_arrival_time = self.fact_time        

      else
        self.location_entity_arrival_time = self.prev_asset_activity_fact.fact_time
      end
    else
      self.location_entity_arrival_time = self.fact_time

    end
  
  end
end
















