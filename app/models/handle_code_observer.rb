class HandleCodeObserver < Mongoid::Observer
	def after_save(record)
		PropagateDescriptionJob.new.handle_code record._id
	end
end
