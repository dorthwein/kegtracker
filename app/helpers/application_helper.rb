module ApplicationHelper
	def title()		
		themes = {
					'Maintenance' => 'class="section-header"', 
					'Scanners' => 'class="section-header"',	
					'Reports' => 'class="section-header"',
					'System' => 'class="section-header"',
					'Browse' => 'class="section-header"'
				}

		section = controller.class.name.split("::").first
		theme = themes[section]
		if !current_user.nil?
			email = current_user.email
		else
			email = ''
		end
		
html = <<html
<div class="section-header" #{theme}>
	<span style="width:33%;float:left; text-align:left;">		
		<br />
	</span>
	<span style="width:33%;float:left; text-align:center;"> 
		#{section}		

	</span>
	<span style="width:33%;float:left; text-align:right;"> 
		#{email}			
	</span>
</div>
html
		if !section.include?('Controller')		
			 html = html.html_safe
		else	
			
			html = html.gsub('HomeController', 'Dashboard').html_safe
		end
	end

	def footer()
		themes = {
					'Maintenance' => 'class="maintenance"', 
					'Scanners' => 'class="scanners"',	
					'Reports' => 'class="reports"',
					'System' => 'class="system"',
					'Browse' => 'class="browse"'
				}
		section = controller.class.name.split("::").first
		theme = themes[section]

html = <<html	
	<li #{theme} style="display:none">
		<div style="clear:both"> </div>
	</li>
html
		html = html.html_safe
	end

	def new_button
		section = controller.class.name.split("::").first
		string = ""		
#		string += controller.action_name + "_"			
		string += 'new_'
		string += section.downcase + '_' + controller.controller_name.singularize
		string =  string += "_path"
		button = '<div class="toolbar-button">' + ( link_to image_tag('icons/new_document.png', :width => '100%'), eval(string) ) + '<br />' +'New </div>'		
		return button
	end
	def edit_button
		section = controller.class.name.split("::").first
		string = ""
		string += 'edit_'		
		string += section.downcase + '_' + controller.controller_name.singularize
		string =  string += "_path"		
		button = '<div class="toolbar-button">' + ( link_to image_tag('icons/edit_document.png', :width => '100%'), eval(string) ) + '<br />' +' Edit </div>'		
		return button
	end
	def save_button
		button = '<div class="toolbar-button" style="width:50px">' + image_submit_tag('icons/save_document.png', :width => '100%', 'data-role' => 'none') +'<br />' + 'Save </div>'		
		return button
	end
	def cancel_button
		section = controller.class.name.split("::").first
		section_title = controller.controller_name
		section_title = section_title.slice(0,1).capitalize + section_title.slice(1..-1)
		
		string = ""
		string += section.downcase + '_' + controller.controller_name
		image_string = 'icons/' + string + '_index.png'
		string += "_path"				
		button = '<div class="toolbar-button">' + ( link_to image_tag('icons/cancel_document.png', :width => '100%'), eval(string) ) + '<br />  Cancel  </div>'		

	end
	def back_button
		button = '<div class="toolbar-button">' + ( link_to image_tag('icons/back.png', :width => '100%'), "", 'data-role' => 'none', 'data-rel' => 'back' ) +'<br />' + 'Back </div>'		
	end	
	def index_button
		section = controller.class.name.split("::").first
		section_title = controller.controller_name
		section_title = section_title.slice(0,1).capitalize + section_title.slice(1..-1)
		
		string = ""
		string += section.downcase + '_' + controller.controller_name
		image_string = 'icons/' + string + '_index.png'
		string += "_path"				
		button = '<div class="toolbar-button">' + ( link_to image_tag(image_string, :width => '100%'), eval(string) ) + '<br /> List </div>'		
	end
	def module_menu_button
		section = controller.class.name.split("::").first
		string = section.downcase + '_menu_path'
		image_string = 'icons/' + 'module_menu.png'
		button = '<div class="toolbar-button">' + ( link_to image_tag(image_string, :width => '100%'), eval(string) ) +'<br />' +  'Menu </div>'		

	end
	def scanners_menu_button
		section = controller.class.name.split("::").first
		string = ''
		image_string = 'icons/scanners_menu.png'
		button = '<div class="toolbar-button">' + ( link_to image_tag(image_string, :width => '100%'), scanners_menu_path ) +'<br /> Scanners </div>'		

	end
	def maintenance_menu_button
		section = controller.class.name.split("::").first
		string = ''
		image_string = 'icons/maintenance_menu.png'
		button = '<div class="toolbar-button">' + ( link_to image_tag(image_string, :width => '100%'), maintenance_menu_path ) +'<br /> Maintenance </div>'		
	end
	def browse_menu_button
		section = controller.class.name.split("::").first
		string = ''
		image_string = 'icons/browse_menu.png'
		button = '<div class="toolbar-button">' + ( link_to image_tag(image_string, :width => '100%'), browse_menu_path ) +'<br /> Browse </div>'		
	end
	def reports_menu_button
		section = controller.class.name.split("::").first
		string = ''
		image_string = 'icons/reports_menu.png'
		button = '<div class="toolbar-button">' + ( link_to image_tag(image_string, :width => '100%'), reports_viewer_path ) +'<br /> Reports</div>'
	end
	def scanner_rfid_antenna_cancel_button
		image_string = 'icons/cancel_document.png'
		button = '<div class="toolbar-button">' + ( link_to image_tag(image_string, :width => '100%'), scanners_rfid_readers_path ) +'<br /> Cancel</div>'		
	end


# TOOLBAR HELPER
	def toolbar options
		buttons = ''

	# General
		buttons += '<div class="general">'
		if options[:module_menu] == true
			buttons += module_menu_button
		end
		if options[:back] == true 
			buttons = buttons + back_button
		end
		buttons += '</div>'	

	# CRUD
		buttons += '<div class="crud">'
		if options[:save] == true 
			buttons = buttons + save_button
		end
		if options[:cancel] == true 
			buttons = buttons + cancel_button
		end
		if options[:rfid_antenna_cancel] == true 
			buttons += scanner_rfid_antenna_cancel_button
		end
		
		if options[:new] == true
			buttons = buttons + new_button
		end
		if options[:edit] == true
			buttons = buttons + edit_button
		end
		buttons += '</div>'
	# Section Navigation		
		buttons += '<div class="section">'
		if options[:index] == true
			buttons += index_button
		end
		buttons += '</div>'				
	# Module Navigation
		buttons += '<div class="module">'
		if options[:scanners_menu] == true
			buttons += scanners_menu_button		
		end
		if options[:maintenance_menu] == true 
			buttons += maintenance_menu_button
		end
		if options[:browse_menu] == true 
			buttons += browse_menu_button
		end		
		if options[:reports_menu] == true 
			buttons += reports_menu_button
		end		
		
		buttons += '</div>'		
		
html = <<html
	<div class="toolbar" style="display:none"> 
		#{buttons} 		
		<div style="clear:both"> </div>				
	</div> 	
html
msg = ''
if !notice.nil? || !alert.nil?
	msg = <<html
		<div class="ui-li-static ui-li">
			#{notice} #{alert}
		</div>
html
return html.html_safe + msg.html_safe
else
return html.html_safe +  '<div style="margin-bottom:25px">	</div>'.html_safe
end


#		object = controller.class.name.split("::")
#		print 'Test ' + object
=begin
		string = ""	
		if options['new'].nil?

			
		   string =  string += "_path"
	#	   return string
			return link_to image_tag('icons/new_document.png', :width => '100%'), eval(string)
=end
#	end		

=begin
html = <<html
	
html
html = html.html_safe
=end	
	end
end
