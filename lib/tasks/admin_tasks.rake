desc "Schedule Tasks"
task :ten_minute_build => :environment do
	build_report = BuildReport.new(Time.now)
	build_report.network_facts
	build_report.charge_credit_card
	build_report.process_billing
end


task :rebuild_cycle_facts => :environment do
	AssetCycleFact.build_cycle_facts_from_time_line	
end

task :process_payments => :environment do
	Entity.all.each do |x|
		if !x.payment_token.nil?			
			payment_method = SpreedlyCore::PaymentMethod.find(x.payment_token.to_s)
			if payment_method.valid?
				purchase_transaction = payment_method.purchase(550)
				#print purchase_transaction.succeeded? # true
			else
			  print "Woops!\n" + payment_method.errors.join("\n")
			end
		end
	end
end

task :thirty_day_build => :environment do
	start = Time.now - 2592000 
	last = Time.now # + 86400
	current = start
	while current < last
		current = current + 86400
		print current.to_s + "\n"		
		a = BuildReport.new(current)	
		print '--- Day Completed'
		a.network_facts
	end	
end

task :invoice_detail_to_attached_asset => :environment do
	Invoice.all.each do |x|
		x.invoice_detail_to_attached_asset
	end
end
task :asset_activity_fact_to_asset_cycle_fact => :environment do
	facts = AssetActivityFact.all
	count = facts.count
	i = 0
	facts.each do |x|
		x.sync_to_asset_cycle_fact		
		i = i + 1
		print "#{i} / #{count} \n "
	end
end

task :save_asset_cycle_facts => :environment do
	facts = AssetCycleFact.all
	count = facts.count
	i = 0
	facts.each do |x|
		x.save!
		i = i + 1
		print "#{i} / #{count} \n "
	end
end

task :save_entities => :environment do
	Entity.all.each do |x|
		if x.save!
			print "Entity Saved \n"
		end
	end
end

task :save_locations => :environment do
	Location.all.each do |x|
		if x.save!
			print "Location Saved \n"
		end
	end
end

task :save_networks => :environment do
	Network.all.each do |x|
		if x.save!
			print "Network Saved \n"
		end
	end
end

task :save_asset_summary_facts => :environment do
	AssetSummaryFact.all.each do |x|
		if x.save!
			print "Asset Summary Fact Saved \n"
		end
	end
end

task :save_asset_activity_facts => :environment do
	AssetActivityFact.all.asc(:fact_time).each do |x|
		if x.save!
			print "Asset Activity Fact Saved \n"
		end
	end
end
task :save_asset_types => :environment do
	AssetType.all.each do |x|
		if x.save!
			print "Asset Type Saved \n"
		end
	end
end


task :save_assets => :environment do
	i = 0
	Asset.all.each do |x|
		if x.save!
			i = i + 1
			print "Asset Saved #{i} \n"
		end
	end
end
task :save_invoices => :environment do
	Invoice.all.each do |x|
		if x.save!
			print "Invoice Saved \n"
		end
	end
end

task :number_to_invoice_number => :environment do
	Invoice.all.each do |x|
		x.invoice_number = x.number
		x.save!
		print "Invoice Number Updated \n"
	end
end

task :save_all => :environment do 
	AssetCycleFact.all.each do |x|
		if x.save!
			print "Asset Cycle Fact Saved \n"
		end
	end

	Entity.all.each do |x|
		if x.save!
			print "Entity Saved \n"
		end
	end
	
	Location.all.each do |x|
		if x.save!
			print "Location Saved \n"
		end
	end

	Network.all.each do |x|
		if x.save!
			print "Network Saved \n"
		end
	end
	Asset.all.each do |x|
		if x.save!
			print "Asset Saved \n"
		end
	end
	AssetActivityFact.all.each do |x|
		if x.save!
			print "Asset Activity Fact Saved \n"
		end
	end
	Invoice.all.each do |x|
		if x.save!
			print "Invoice Saved \n"
		end
	end
	InvoiceLineItem.all.each do |x|
		if x.save!
			print "Invoice Line Item Saved \n"
		end
	end

	Product.all.each do |x|
		if x.save!
			print "Product Saved \n"
		end
	end
	AssetType.all.each do |x|
		if x.save!
			print "Asset Type Saved \n"
		end
	end

	
end
task :save_network_facts => :environment do
	NetworkFact.all.each do |x|		
		if x.save!
			print "Network Fact Saved \n"
		end
	end
end

task :correct_cross_brewer => :environment do
	Asset.all.excludes(:location_network => nil).each do |x|
		if x.location_network.network_type == 1
			if x.product.entity != x.location_network.entity
				x.product = nil
				x.save!

				print "Asset Corrected \n"
			end
		end
	end
	AssetActivityFact.all.excludes(:location_network => nil).each do |x|
		if x.location_network.network_type == 1
			if x.product.entity != x.location_network.entity
				x.product = nil
				x.save!
				print "Asset Activity Fact Corrected \n"
			end
		end
	end	
end