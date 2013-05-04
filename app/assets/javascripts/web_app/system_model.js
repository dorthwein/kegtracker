var settings = {"version":"1.0","theme":'metro'};
var system = {};

$(window).resize(function() {  	
	setViews();
});
function toThemeProperty(className) {
    return className + " " + className + "-" + settings.theme;
}
 function default_groupsrenderer(text, group, expanded, data) {	
	return '<div class="' + toThemeProperty('jqx-grid-groups-row') + '" style="position: absolute; width:100%;">	<span>' + group + '</span> </div>';
}

function jqxGridColumnListBoxWidth(){
	return '80%;'
}


function setViews(){	
	var displayWidth =  $(window).width() - $('.full.sidebar').outerWidth();
	var jqxGridHeight = $(window).height() - $('.toolbar').outerHeight() - $('#footer').outerHeight();

	
	
	$('.jqxGridColumnListBox').jqxListBox({width: '100%' });
	$('.jqxGrid.full.display').jqxGrid({width:'100%', height: jqxGridHeight});

	$('.full.display').width(displayWidth);

	$('.full.display').height(	$(window).height() - $('#footer').outerHeight()); // $('.toolbar').outerHeight() <-- Add this to include toolbar

	$('.full.sidebar').height($(window).height() - 20);

	$('.jqxValidator').jqxValidator('updatePosition');
}


// Default Grid Settings
settings.jqxGridProperties = {
	groupable: true,
	sortable: true,
    autoshowfiltericon: true,
	theme: settings.theme,
	width: '100%',
	groupsexpandedbydefault: true,
	groupsrenderer: default_groupsrenderer,		
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


	$('.expandable .title').on('click', function(){
		if($(this).parent().hasClass('active')){
			$(this).parent().children('.content').hide();
			$(this).parent().children('.content').removeClass('active')
			$(this).parent().removeClass('active')
			$(this).removeClass('active')
		} else{
			$(this).parent().children('.content').show();
			$(this).parent().children('.content').addClass('active')
			$(this).parent().addClass('active')
			$(this).addClass('active')

		}
		setViews();
	});


/*	
Rails Ajax Callbacks
	.bind('ajax:beforeSend', function(xhr, settings) {})
	.bind('ajax:success',    function(xhr, data, status) {})
	.bind('ajax:complete', function(xhr, status) {})
	.bind('ajax:error', function(xhr, data, status) {})
*/

	$('#modal_box').on('ajax:success', 'form', function(){
		window.parent.dataAdapter.dataBind();					
		$('#modal_box').hide();
		$('#page_view').removeClass('modal-blur');
		$('#modal_box').jqxValidator('destroy');						
	});

	$("#modal_box").on('click', '.cancel', function () {		
		$('#modal_content').html(' ');
		$('#page_view').removeClass('modal-blur');
		$('#modal_box').hide();
		$('#modal_box').jqxValidator('destroy');						
	});

	$("#modal_box").on('click', 'input[type=submit]', function(event) {	    
	    if($('#modal_box').jqxValidator('validate') == false){			
			event.preventDefault();	    	
	    }
	});

	setViews();
//	$('body').show()
	
})




















