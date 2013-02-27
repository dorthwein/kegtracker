class AssetActivityFact
  include Mongoid::Document
  include Mongoid::Timestamps  	

# Created in Scan Object
# Used by report builder to generate report facts

# Fact Details 
  field :fact_time, :type => Time
  field :handle_code, type: Integer, :default => 5

  belongs_to :location

# Asset Details
  belongs_to :asset
  
  belongs_to :entity      # Asset Owner
  belongs_to :product
  belongs_to :asset_type
  
  belongs_to :fill_asset_activity_fact, :class_name => 'AssetActivityFact', :inverse_of => 'AssetActivityFact'
  belongs_to :pickup_asset_activity_fact, :class_name => 'AssetActivityFact', :inverse_of => 'AssetActivityFact'
  belongs_to :delivery_asset_activity_fact, :class_name => 'AssetActivityFact', :inverse_of => 'AssetActivityFact'
  belongs_to :prev_asset_activity_fact, :class_name => 'AssetActivityFact', :inverse_of => 'AssetActivityFact'
# Variable Details 

# Life Cycle
  field :fill_time, :type => Time
  field :fill_count, type: Integer
  field :asset_status, type: Integer, :default => 0  
  field :location_network_type, type: Integer

  field :cycle_length, type: Integer, :default => 0
  field :completed_cycle_length, type: Integer, :default => 0

# Networks  
# belongs_to :network    # Possibly Depricated  
  belongs_to :prev_location_network, :class_name => 'Network'
  belongs_to :location_network, :class_name => 'Network'
  belongs_to :user  
  belongs_to :fill_network, :class_name => 'Network'
  belongs_to :delivery_network, :class_name => 'Network'
  belongs_to :pickup_network, :class_name => 'Network'

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


	before_save :sync
	def sync	    
    self.location_network = self.location.network
    self.location_network_type = self.location_network.network_type rescue nil
    
    self.prev_asset_activity_fact_id = AssetActivityFact.where(:asset => self.asset).lt(fact_time: self.fact_time).desc(:fact_time).first._id
    # Find & Set Previous asset_activity_fact     
    # self.asset_status_description = nil
    if self.handle_code != 4
      self.fill_asset_activity_fact_id = AssetActivityFact.where(:asset => self.asset, :handle_code => 4).lte(fact_time: self.fact_time).desc(:fact_time).first._id
      if !self.fill_asset_activity_fact_id.nil?
        self.cycle_length = self.fact_time.to_i - self.fill_asset_activity_fact.fact_time.to_i        
      end
      
#      if self.fill_asset_activity_fact.nil?
#        self.fill_asset_activity_fact_id = self._id
#      end
    else
      # If filled, updated previous cycle to complete
      if !self.prev_asset_activity_fact.nil?
        prev_fill_fact = self.prev_asset_activity_fact.fill_asset_activity_fact rescue nil        
        if !prev_fill_fact.nil?
          prev_cycle_length = self.fact_time.to_i - prev_fill_fact.fact_time.to_i        
          AssetActivityFact.where(:fill_asset_activity_fact => prev_fill_fact).update_all(:completed_cycle_length => prev_cycle_length)
        end
      end      
      self.fill_asset_activity_fact_id = self._id
      self.fill_network = self.location_network
    end    

    if self.handle_code == 2
      self.pickup_asset_activity_fact_id = self._id
      self.pickup_network = self.location_network

      AssetActivityFact.where(:fill_asset_activity_fact => self.fill_asset_activity_fact).update_all(:pickup_network_id => self.location_network._id, :pickup_asset_activity_fact_id => self._id)
    end
    if self.handle_code == 1
      self.delivery_asset_activity_fact_id = self._id
      self.delivery_network = self.location_network
      AssetActivityFact.where(:fill_asset_activity_fact => self.fill_asset_activity_fact).update_all(:delivery_network_id => self.location_network._id, :delivery_asset_activity_fact_id => self._id)
    end    
    self.fill_time = self.fill_asset_activity_fact.fact_time rescue nil
	end  
end
