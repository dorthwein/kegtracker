desc "Schedule Tasks"
task :ten_minute_build => :environment do
	build_report = BuildReport.new(Time.new)
	build_report.asset_summary_fact
	build_report.asset_location_network_in_out_report
	build_report.asset_activity_summary_fact 	

end

task :build_asset_summaries => :environment do
	start = Time.new(2012,"dec", 1)
	last = Time.new() # + 86400
	current = start

	while current < last
		current = current + 86400
		print current.to_s + "\n"		
		a = BuildReport.new(current)	
		a.asset_summary_fact 
		a.asset_location_network_in_out_report
	end	
end

task :build_asset_activity_summaries => :environment do
	start = Time.new(2012,"oct", 1)
	last = Time.new() # - 86400
	current = start

	while current < last
		current = current + 86400
		print current.to_s + "\n"		
		a = BuildReport.new(current)	
		a.asset_activity_summary_fact 
	end	
end

task :save_asset_activity_facts => :environment do
	AssetActivityFact.all.each do |x|
		if x.save!
			print "Asset Activity Fact Saved \n"
		end
	end
end

task :save_assets => :environment do
	Asset.all.each do |x|
		if x.save!
			print "Asset Saved \n"
		end
	end
end



task :convert_handle_code_relation_to_handle_code_field => :environment do
	HandleCode.all.each do |hc_relation|
		Asset.where(:handle_code_id => hc_relation._id ).set(:handle_code, hc_relation.code.to_i)
		AssetActivityFact.where(:handle_code_id => hc_relation._id ).set(:handle_code, hc_relation.code.to_i)
	end
end

task :convert_asset_state_to_asset_status => :environment do
#	full_asset_state =  '5069db72a682140200000002' # AssetState.where(:description => 'Full').first
#	empty_asset_state = '5069db6ca682140200000001'	# AssetState.where(:description => 'Empty').first
#	market_asset_state = '5087079c4976f70200000009' # AssetState.where(:description => 'Market').first


        
	AssetActivityFact.where(asset_state_id: {"$oid" => "5069db72a682140200000002"}).set(:asset_status, 1)
	AssetActivityFact.where(asset_state_id: {"$oid" => "5069db6ca682140200000001"}).set(:asset_status, 0)
	AssetActivityFact.where(asset_state_id: {"$oid" => "5087079c4976f70200000009"}).set(:asset_status, 2)

#	Asset.where(asset_state_description: 'Full').set(:asset_status, 1)
#	Asset.where(asset_state_description: 'Empty').set(:asset_status, 0)
#	Asset.where(asset_state_description: 'Market').set(:asset_status, 2)
end