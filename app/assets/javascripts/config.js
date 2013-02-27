
$(document).on("mobileinit", function(){
	$.mobile.defaultPageTransition  = 'none';
}); 

$(document).on('pagebeforehide', function(event){
	$(window).unbind('keydown');
	console.log('unboud');
});
$(document).on('pageshow', function(event){
	// Load jqX Menu at startup	
	$("#jqxMenu").jqxMenu({ 	width: '100%', 
								height: 30,
								autoOpen: false,
								theme: settings.theme,
								animationShowDuration: 0,
								animationHideDuration: 0,
								animationShowDelay: 0 

							});	
//		// Unbinding incase previously bound to prevent multiple sends
	$(window).keydown(function(event) {				
		if(event.keyCode == '13'){
			$(':focus').blur()
		}
	});	

//	$("#jqxMenu").show();
});

