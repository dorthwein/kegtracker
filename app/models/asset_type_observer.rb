class AssetTypeObserver < Mongoid::Observer

#	def after_save(record)
#		PropagateDescriptionJob.new.asset_type record._id
#	end

end
