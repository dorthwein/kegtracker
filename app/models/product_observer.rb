class ProductObserver < Mongoid::Observer
#	def after_save(record)
#		PropagateDescriptionJob.new.product record._id
#	end
end
