class EmailProcessDrone
	def initialize
#	end
#	def check_email
		users = User.all	
		imap = Net::IMAP.new('imap.gmail.com', 993, true, nil, false)
		imap.login('dorthwein@gmail.com', 'virginia101')
		imap.examine('INBOX')
		before = Date.today.strftime("%d-%b-%Y")
		since = (Date.today - 2).strftime("%d-%b-%Y")
		print before
		print "\n"
		print since
		users.each do |user|		
			Rsl.new(user)
		end

		imap.logout
		imap.disconnect
	end
	handle_asynchronously :initialize
end
