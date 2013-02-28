var settings = {"version":"1.0","theme":'metro'};
var pgFunc = {};
var params = {};
var system = {};

system.background = {};
system.background.intervals = {};	// Not sure what this is for...?



x = function(){
	var height = $(window).height() - 150;
	return height	
}
$(window).resize(function() {  
	$('.jqxValidator').jqxValidator('updatePosition');
//	$("#jqxgrid").jqxGrid({height:x()});
});

toThemeProperty = function (className) {
    return className + " " + className + "-" + settings.theme;
}
default_groupsrenderer = function (text, group, expanded, data) {
	return '<div class="' + toThemeProperty('jqx-grid-groups-row') + '" style="position: absolute; width:100%;">	<span>' + group + '</span> </div>';
}

system.full_window_table_height = '800px'
system.table_height = '625px'
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

$(document).on('pagehide', function(event, ui){
	var page = jQuery(event.target);
	if(page.attr('data-cache') == 'never'){
		page.remove();
	};
});
