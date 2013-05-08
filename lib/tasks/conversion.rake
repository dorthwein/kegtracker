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