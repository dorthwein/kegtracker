desc "Schedule Tasks"
task :ten_minute_build => :environment do
	build_report = BuildReport.new(Time.now)
	build_report.network_facts
	build_report.charge_credit_card
	build_report.process_billing
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


task :check_for_overdue_assets => :environment do	
	Entity.all.each do |entity|
		entity.distribution_partnerships.each do |distribution_partnership|
			stagnant_date = Time.new - (distribution_partnership.overdue_time * 84000)
			entity.visible_assets.where(location_entity_id: distribution_partnership.partner, :location_entity_arrival_time.lt => stagnant_date).update_all(:asset_overdue => 1)
			entity.visible_assets.where(location_entity_id: distribution_partnership.partner, :location_entity_arrival_time.gt => stagnant_date).update_all(:asset_overdue => 0)
		end
	end
end

