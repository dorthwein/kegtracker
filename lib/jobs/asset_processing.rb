class AssetProcessing
	def initialize

	end

	def self.check_overdue_assets
		Entity.all.each do |entity|
			entity.distribution_partnerships.each do |distributor_partnership|
				entity.visible_assets.where()

				distributor_partnership.concern_time
			end
			# Get Entity Distributor Partnerships

			# For each partnership
				# Set assets that have been their longer than the concern time to late

			# 
			# 
		end
	end
end
