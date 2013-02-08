class InvoiceAssetDetails
	include Mongoid::Document

	belongs_to :invoice

	belongs_to :asset

	belongs_to :invoice_asset_activity_fact, :class_name => 'AssetActivityFact'
	belongs_to :return_asset_activity_fact, :class_name => 'AssetActivityFact'

	belongs_to :location_network, :class_name => 'Network'

	# belongs_to :invoice_asset_activity_fact, :class_name => 'AssetActivityFact'

	belongs_to :asset_type
	belongs_to :product

	field :asset_status, type: Integer



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
end

