class AssetCycleFact
  include Mongoid::Document
  include Mongoid::Timestamps  	

# Created in Scan Object
# Used by report builder to generate report facts

	has_many :asset_activity_facts
# Fact Details 
	belongs_to :entity      # Asset Owner
	belongs_to :product		# Asset Product
	belongs_to :asset_type
  	belongs_to :asset  
  
	field :start_time, type: Time
	field :fill_time, type: Time
	field :delivery_time, type: Time
	field :pickup_time, type: Time
	field :end_time, type: Time
	
	belongs_to :start_asset_activity_fact, class_name: 'AssetActivityFact' #, 		:inverse_of => 'AssetActivityFact'  	
  	belongs_to :fill_asset_activity_fact, class_name: 'AssetActivityFact' #, 		:inverse_of => 'AssetActivityFact'
  	belongs_to :pickup_asset_activity_fact, class_name: 'AssetActivityFact' #, 	:inverse_of => 'AssetActivityFact'
  	belongs_to :delivery_asset_activity_fact, class_name: 'AssetActivityFact' #, 	:inverse_of => 'AssetActivityFact'
	belongs_to :end_asset_activity_fact, class_name: 'AssetActivityFact' #, 		:inverse_of => 'AssetActivityFact'  	

	field :fill_count, type: Integer
#  	field :cycle_length, type: Integer, default: 0
  	field :completed_cycle_length, type: Integer, default: 0

	field :cycle_complete, type: Integer, default: 0 # yes/no
	
	# 0 = Bad Quality
	# 1 = Good Quality - Fill, Delivery, & Pickup
	field :cycle_quility, type: Integer, default: 0

  	belongs_to :start_network, class_name: 'Network'
  	belongs_to :fill_network, class_name: 'Network'
  	belongs_to :delivery_network, class_name: 'Network'
  	belongs_to :pickup_network, class_name: 'Network'
  	belongs_to :end_network, class_name: 'Network'

  	belongs_to :fill_user, class_name:'User', inverse_of: 'User'
  	belongs_to :delivery_user, class_name: 'User', inverse_of: 'User'
  	belongs_to :pickup_user, class_name: 'User', inverse_of: 'User'
  
	def fill

	end
	
	def delivery

	end

	def pickup

	end

	def end_cycle

	end

	before_create :start_cycle
	def start_cycle

	end

	before_save :sync
	def sync
		
		# Determine Start


		if !self.end_asset_activity_fact.nil?

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
end
