class AssetActivityFact
  include Mongoid::Document
  include Mongoid::Timestamps  	

# Created in Scan Object
# Used by report builder to generate report facts

# Fact Details 
  field :fact_time, :type => Time
  field :handle_code, type: Integer

  belongs_to :location

# Asset Details
  belongs_to :asset
  belongs_to :entity      # Asset Owner
  belongs_to :product
  belongs_to :asset_type
  
  belongs_to :fill_asset_activity_fact, :class_name => 'AssetActivityFact'  
  belongs_to :prev_asset_activity_fact, :class_name => 'AssetActivityFact'

# Variable Details 
# Life Cycle
# field :fill_time, :type => Time
  field :fill_count, type: Integer
  field :asset_status, type: Integer 

# Networks  
# belongs_to :network    # Possibly Depricated  
  belongs_to :prev_location_network, :class_name => 'Network'
  belongs_to :location_network, :class_name => 'Network'
  belongs_to :user  
#  belongs_to :fill_network, :class_name => 'Network'

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
    # Find & Set Previous asset_activity_fact     
    # self.asset_status_description = nil
    if self.handle_code != 4
      self.fill_asset_activity_fact = AssetActivityFact.where(:asset => self.asset, :handle_code => 4).lte(fact_time: self.fact_time).desc(:fact_time).first
      if self.fill_asset_activity_fact.nil?
        fill_asset_activity_fact = self._id
      end


    else
      self.fill_asset_activity_fact_id = self._id
    end

    self.prev_asset_activity_fact = AssetActivityFact.where(:asset => self.asset).lt(fact_time: self.fact_time).desc(:fact_time).first    

    
    # If nil, use current network
    if prev_asset_activity_fact.nil?
      self.prev_location_network = nil # self.location_network    
    # else use previous activity fact
    else
      self.prev_location_network = prev_asset_activity_fact.location_network
    end
	end  
end
