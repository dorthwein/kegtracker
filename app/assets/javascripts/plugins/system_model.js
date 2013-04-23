var settings = {"version":"1.0","theme":'metro'};
var pgFunc = {};
var params = {};
var system = {};

system.background = {};
$(window).resize(function() {  
	$('.jqxValidator').jqxValidator('updatePosition');	
	$('.jqxGrid.full.display').jqxGrid({height: jqxGridFullWindowHeight()});
	$('.jqxGridColumnListBox').jqxListBox({height: jqxGridColumnListBoxHeight()});
//	$('#content').height(system.full_window_table_height() - 60)
//	$("#jqxGrid").jqxGrid({height:x()});
});


function toThemeProperty(className) {
    return className + " " + className + "-" + settings.theme;
}
 function default_groupsrenderer(text, group, expanded, data) {	
	return '<div class="' + toThemeProperty('jqx-grid-groups-row') + '" style="position: absolute; width:100%;">	<span>' + group + '</span> </div>';
}

function jqxGridColumnListBoxHeight(){
	var height = $(window).height() - 280;
	return height
}
function jqxGridFullWindowHeight(){
	var height = $(window).height() - 130;
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
	height: jqxGridFullWindowHeight(),		
	columnsresize: true,
	autoshowcolumnsmenubutton:false,
	rowsheight:35,
	showfiltercolumnbackground: false,
	selectionmode: 'multiplerowsextended',
}

system.simple_grid_height = '800px';
system.simple_grid_width = '958px';

system.popup_settings = 'width=800,height=500, menubar=no, titlebar=no, toolbar=no, status=no';

system.server = 'http://' + window.location.host;

$(document).ready(function(){	
// Load Menu Bar
	$("#jqxMenu").jqxMenu({ 	
		width: '100%', 
		height: 30,
		width:'100%',
		enableHover:true,
		autoOpen: true,
		theme: settings.theme,
		animationShowDuration: 0,
		animationHideDuration: 0,
		animationShowDelay: 0 
	});	
	$('#report_select_menu').val(location.href)

	$("#report_select_menu").on('change', function(){
		location.href = $(this).val()
	})
})









