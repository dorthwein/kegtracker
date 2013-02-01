=begin
class ScanDrone
	require 'S1'
#	require 'scan_object'	
	require 'scan_process'		
	require 'T0'	
	require 'T1'
	attr_accessor :processed_scans
	def initialize scans
		@processed_scans = Array.new
		scans.each do |scan|
			scan_obj = JSON.parse(scan)	

			scan = ScanProcess.new(scan_obj)
			@processed_scans.push(scan.scan_snap_shot)
		end
	end	
end
=end