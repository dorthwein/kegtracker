class UserObserver < Mongoid::Observer
#	def after_save(record)
#		PropagateDescriptionJob.new.user record._id
#	end
end
