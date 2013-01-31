class Rsl < EmailProcessDrone
	def initialize user
		imap.search(["SINCE", since,"FROM", user.email]).each do |message_id|
			envelope = imap.fetch(message_id, "BODY[2]")[0]["attr"]["BODY[2]"]
			csv_format = Base64.decode64(envelope)		
			CSV.parse("CSV,#{csv_format},String") do |row|
				ext_id_start = row[0].index('(').to_i + 1
				ext_id_end = row[0].index(')').to_i - 1
				ext_id = row[0][ext_id_start..ext_id_end]
				location = Location.where(:externalID => ext_id, :entity => user.entity).first
				if location.nil?
					Location.create(
						:externalID => ext_id,
						:description => row[0].gsub("'", " "),
						:street => row[1],
						:city => row[2][4..-1],
						:state => row[3],						
						:zip => row[4],
						:on_premise => true,
						:off_premise => true,
						:network => user.entity.networks[0],
						:entity => user.entity
					)
				else
					location.update_attributes(
						:externalID => ext_id,
						:description => row[0].gsub("'", " "),
						:street => row[1],
						:city => row[2][4..-1],
						:state => row[3],						
						:zip => row[4],
						:on_premise => true,
						:off_premise => true,
						:network => user.entity.networks[0],
						:entity => user.entity
					)
				end					
			end		
		end  		
	end
end
