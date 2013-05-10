desc "Conversion Tasks"
task :convert_to_scopped_locations => :environment do
	Location.where(location_type: 5).each do |x|
		x.update_attributes(scope: 1)
	end
end


task :test_report => :environment do 
	start = Time.now # - 2592000
	build_report = BuildReport.new(start)
	build_report.daily_facts
end

task :convert_asset_status_description => :environment do
	facts = AssetActivityFact.all
	i = 0
	facts.each do |x|
		x.set_asset_status
		x.save!
		i = i + 1
		print i.to_s + ' / ' + facts.count.to_s + " \n "
	end
end

task :purge_dead_asset_activity_facts => :environment do
	Asset.where(entity_id: nil).each do |x|
		x.delete
	end
	Asset.where(asset_activity_fact: nil).each do |x|
		x.delete
	end
	assets = Asset.all.map{|x| x._id}
	activity_facts = AssetActivityFact.not_in(:asset_id => assets)
	activity_facts.each do |x|
		x.delete
	end

end

task :view_dead_asset_activity_facts => :environment do
	print Asset.where(entity_id: nil).count.to_s + "<--- Asset with No Owner # \n"
	
	
	print Asset.where(asset_activity_fact: nil).count.to_s + "<--- Asset with no Activity Fact"
		
	assets = Asset.all.map{|x| x._id}

	print AssetActivityFact.not_in(:asset_id => assets).count.to_s + "<---- Activity Fact with no asset"
	

end

