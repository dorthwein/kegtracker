var settings = {"version":"1.0","theme":'metro'};
var system = {}
system.server = 'http://' + window.location.host;
$(document).ready(function(){	
// Load Menu Bar
	$("#jqxMenu").jqxMenu({ 	
		width: '100%', 
		height: '100%',
		width:'100%',
		enableHover:true,
		autoOpen: true,
		theme: settings.theme,
		animationShowDuration: 0,
		animationHideDuration: 0,
		animationShowDelay: 0 
	});	

/*
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
*/

/*	
Rails Ajax Callbacks
	.bind('ajax:beforeSend', function(xhr, settings) {})
	.bind('ajax:success',    function(xhr, data, status) {})
	.bind('ajax:complete', function(xhr, status) {})
	.bind('ajax:error', function(xhr, data, status) {})
*/

//	$('body').show()
	
})




















