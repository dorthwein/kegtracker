class LocationObserver < Mongoid::Observer
	def after_save(record)
		PropagateDescriptionJob.new.location record._id
	end
end
