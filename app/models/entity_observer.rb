class EntityObserver < Mongoid::Observer
	def after_save(record)
		PropagateDescriptionJob.new.entity record._id
	end
end
