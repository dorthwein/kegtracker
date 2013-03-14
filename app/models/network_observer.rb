class NetworkObserver < Mongoid::Observer
#	def after_save(record)	
#		PropagateDescriptionJob.new.network record._id
#	end
end
