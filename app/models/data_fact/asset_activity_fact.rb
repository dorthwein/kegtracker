class AssetActivityFact
  include Mongoid::Document
  include Mongoid::Timestamps  	
  field :record_status, type: Integer, default: 1

# Created in Scan Object
# Used by report builder to generate report facts

# Fact Details 
  field :fact_time, :type => Time
  field :handle_code, type: Integer, :default => 5
  
  has_one :invoice_attached_asset

  belongs_to :location

# Asset Details
  belongs_to :asset
  
  belongs_to :entity      # Asset Owner
  belongs_to :product
  belongs_to :asset_type
  belongs_to :sku
  
  belongs_to :asset_cycle_fact, inverse_of: 'AssetCycleFact'

# ALL BEING DEPRICATED
  belongs_to :fill_asset_activity_fact, :class_name => 'AssetActivityFact',     :inverse_of => 'AssetActivityFact'
  belongs_to :pickup_asset_activity_fact, :class_name => 'AssetActivityFact',   :inverse_of => 'AssetActivityFact'
  belongs_to :delivery_asset_activity_fact, :class_name => 'AssetActivityFact', :inverse_of => 'AssetActivityFact'
  belongs_to :prev_asset_activity_fact, :class_name => 'AssetActivityFact',     :inverse_of => 'AssetActivityFact'

# Variable Details 

# Life Cycle  
  field :fill_time, :type => Time   # Depricated
  field :fill_count, type: Integer

  field :asset_status, type: Integer, :default => 0  
  field :location_network_type, type: Integer

  field :cycle_length, type: Integer, :default => 0 # Depricated
  field :completed_cycle_length, type: Integer, :default => 0 # Depricated

# Networks  
# belongs_to :network    # Possibly Depricated  
  belongs_to :prev_location_network, :class_name => 'Network' # Depricated? - Check Scanning
  belongs_to :location_network, :class_name => 'Network'
  
  belongs_to :user  
  belongs_to :fill_network, :class_name => 'Network'          # Depricated
  belongs_to :delivery_network, :class_name => 'Network'      # Depricated
  belongs_to :pickup_network, :class_name => 'Network'        # Depricated

# Activity

# Reporting
  def asset_status_description
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

  def handle_code_description
    case self.handle_code.to_i
    when 1
      return 'Delivery' 
    when 2
      return 'Pickup'
    when 3
      return 'Add'
    when 4
      return 'Fill'
    when 5
      return 'Move'
    when 6
      return 'RFNet'
    when 7
      return 'Audit'
    end
  end

  def self.create_from_asset asset
    details = {
                  :asset_id => asset._id,
                  :asset_status => asset.asset_status,
                  :asset_type_id => asset.asset_type_id,                                   
                  :entity_id => asset.entity_id,

                  :product => asset.product,
                  :handle_code => asset.handle_code.to_i,                  
                  :fact_time => asset.last_action_time,
                  :fill_count => asset.fill_count.to_i,
                  
                  :location_id => asset.location_id,
                  :location_network_id => asset.location_network_id,
  #                 :network => self.network, Possible Depricated
  #                 :fill_network => self.fill_network,
                  :user => asset.user,
  #                 :fill_time => asset.fill_time,                
                }
    AssetActivityFact.create(details)
  end

	# Temp migration file etc...
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
        :entity => (self.prev_asset_activity_fact.entity rescue nil),
        :product => (self.prev_asset_activity_fact.product rescue nil),
        :asset_status => (self.prev_asset_activity_fact.asset_status rescue nil),
        :location => (self.prev_asset_activity_fact.location rescue nil),
        :location_network => (self.prev_asset_activity_fact.location_network rescue nil),
        :handle_code => (self.prev_asset_activity_fact.handle_code rescue nil),
        :user => (self.prev_asset_activity_fact.user rescue nil),
        :last_action_time => (self.prev_asset_activity_fact.fact_time rescue nil),
        :fill_count => (self.prev_asset_activity_fact.fill_count rescue 0),
      }
      self.asset.update_attributes(asset_rollback)              
    end

    # Find items attached to an invoice and remove it
    self.invoice_attached_asset.delete rescue nil
    
    # Find asset cycle fact and correct it
    if self.asset_cycle_fact.fill_asset_activity_fact == self
        self.asset_cycle_fact.update_attributes(fill_asset_activity_fact: nil, fill_time: nil, fill_network: nil)    
    end

    if self.asset_cycle_fact.pickup_asset_activity_fact == self
        self.asset_cycle_fact.update_attributes(pickup_asset_activity_fact: nil, pickup_time: nil, pickup_network: nil)
    end

    if self.asset_cycle_fact.delivery_asset_activity_fact == self
        self.asset_cycle_fact.update_attributes(delivery_asset_activity_fact: nil, delivery_time: nil, delivery_network: nil)
    end

    if self.asset_cycle_fact.end_asset_activity_fact == self
        self.asset_cycle_fact.update_attributes(end_asset_activity_fact: nil, end_time: nil,  end_network: nil)
    end

    if self.asset_cycle_fact.start_asset_activity_fact == self
        self.asset_cycle_fact.destroy
    end

    # Delete self 
    print 'Asset Rollback'
  end


  before_save :sync
	def sync	    
    self.location_network = self.location.network
    self.location_network_type = self.location_network.network_type rescue nil
    self.prev_asset_activity_fact_id = AssetActivityFact.where(:asset => self.asset).lt(fact_time: self.fact_time).desc(:fact_time).first._id
    self.sku = Sku.find_or_create_by(entity: self.product.entity, primary_asset_type: self.asset_type, product: self.product)
  end
end