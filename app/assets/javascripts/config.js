$(document).bind("mobileinit", function(){
	$.mobile.defaultPageTransition  = 'none';
}); 

$(document).bind('pagebeforehide', function(event){

});
$(document).bind('pageshow', function(event){
	// Load jqX Menu at startup
	$("#jqxMenu").jqxMenu({ 	width: '100%', 
								height: 30,
								autoOpen: false,
								theme: settings.theme,
								animationShowDuration: 0,
								animationHideDuration: 0,
								animationShowDelay: 0 

							});	
//	$("#jqxMenu").show();
});