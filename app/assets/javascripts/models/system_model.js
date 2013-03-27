var settings = {"version":"1.0","theme":'metro'};
var pgFunc = {};
var params = {};
var system = {};

system.background = {};
system.background.intervals = {};	// Not sure what this is for...?

$(window).resize(function() {  
	$('.jqxValidator').jqxValidator('updatePosition');	
	$('.jqxGrid.full.display').jqxGrid({height: system.full_window_table_height()});
	$('.jqxGridColumnListBox').jqxListBox({height: (system.full_window_table_height() - 150)});
//	$("#jqxGrid").jqxGrid({height:x()});
});


toThemeProperty = function (className) {
    return className + " " + className + "-" + settings.theme;
}
default_groupsrenderer = function (text, group, expanded, data) {	
	return '<div class="' + toThemeProperty('jqx-grid-groups-row') + '" style="position: absolute; width:100%;">	<span>' + group + '</span> </div>';
}

system.full_window_table_height = function(){
									var height = $(window).height() - 125;
									return height	
								} //	 '800px'

// Default Grid Settings
settings.jqxGridProperties = {
		groupable: true,
		sortable: true,
        autoshowfiltericon: true,
		theme: settings.theme,
		width: '100%',
		groupsexpandedbydefault: true,
		groupsrenderer: default_groupsrenderer,		
		height:  system.full_window_table_height(),		
		columnsresize: true,
		autoshowcolumnsmenubutton:false,
		rowsheight:35,
		showfiltercolumnbackground: false,
}

system.simple_grid_height = '800px';
system.simple_grid_width = '958px';

system.popup_settings = 'width=800,height=500, menubar=no, titlebar=no, toolbar=no, status=no';

system.server = 'http://' + window.location.host;
// system.server = 'http://www.craft-net.com/';
// system.server = 'http://localhost:3000/';
// system.server = 'http://192.68.1.74:3000/';
	console.log('Server: ' + system.server);
// Background Processes
system.func = {}
// ***************************
// Prevent Cacheing
// ***************************
$(document).on('pagebeforehide', function(event, ui){
//	$('.jqxValidator').jqxValidator('destroy');
	$('.jqx-validator-hint').remove();	
});


$(document).on('pagehide', function(event, ui){
	var page = jQuery(event.target);
	if(page.attr('data-cache') == 'never'){
		page.remove();
	};
});
