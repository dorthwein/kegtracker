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
//	$("#jqxgrid").jqxGrid({height:x()});
});

toThemeProperty = function (className) {
    return className + " " + className + "-" + settings.theme;
}
default_groupsrenderer = function (text, group, expanded, data) {
	return '<div class="' + toThemeProperty('jqx-grid-groups-row') + '" style="position: absolute; width:100%;">	<span>' + group + '</span> </div>';
}


system.table_height = '625px'
system.simple_grid_height = '800px';
system.simple_grid_width = '958px';

// window.location.protocol = "http"


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

$(document).bind('pagehide', function(event, ui){
	var page = jQuery(event.target);
	if(page.attr('data-cache') == 'never'){
		page.remove();
	};
});

system.func.scanProcessing = function(sync){
    var mode = sync
	function scanQuery(tx){
		// Scan Validation etc...
		sql = 'SELECT * FROM scans';
		
		tx.executeSql(sql,[], scanCallback, database.error);
		tx.executeSql( sql );
	}
	function scanCallback(tx, results){
		// IF > 1 Scan, SEND TO SERVER
		if(results.rows.length > 0){		
			console.log('Sending Scans');			
            var scanEvents = [];
            
	        var len = results.rows.length;                	    
            for (var i=0; i<len; i++){
//                console.log(results.rows.item(i).scan);
                scanEvents.push($.parseJSON(results.rows.item(i).scan));                
            };
            			
			// SEND SCANS
            var url = system.server + 'scanner/scan.json';
//            console.log('Sending as: ' + mode);
            $.ajax({
                   url: url,	
                   type: "POST",
                   data: { scan : JSON.stringify(scanEvents) },				   
				   dataType: "JSON",
                   success: function( data ){    		    		    		      			                  
						// Update Recents table
						for (var i=0; i < data.length; i++){
							var tag = data[i];
							var d = new Date();							
							$('#scanAlerts').dataTable().fnAddData( [

								d.toLocaleTimeString(),
								tag.Network, 
								tag.Value, 
								tag.Location, 
								tag.Brewery,
								tag.Product,
								tag.Size, 
								tag.Action
							] );
							
//							$('#scanAlerts').prepend('<tr> <td>' + tag.Network + ' </td> <td> ' + tag.Value + '  </td> <td> ' + tag.Location + ' </td> <td> ' + tag.Brewery + '  </td> <td> ' + tag.Product + ' </td> <td> ' + tag.Size + ' </td> <td> ' + tag.Action + ' </td> </tr>');
						};
					
                        // Delete Query                        
                        function deleteQuery(tx){
                            tx.executeSql('DELETE FROM SCANS');
                            console.log('Data: Sent, current scan table cleared');	
                        }                           
                        database.access.transaction(deleteQuery, database.error);                        
                        $(this).addClass("done"); 

                   },
                   error: function( data ){
						console.log('Connection Failed');
						console.log(JSON.stringify(data));
                   }
            }); 	
		} 
		// NO SCANS
		else if(results.rows.length == 0 || results.rows.length == undefined){
			$('#scanNotification').html('<div> No Pending Scans </div>');			
		} 		
		// ERROR GETTING SCANS
		else {			
			console.log('SQL Error')
			$('#scanNotification').html('<div> Scan table still loading... scans may not save </div>');
		} 
	};		
// Check for Internet	   

	database.access.transaction(scanQuery,database.error);		
};

//setInterval("system.func.scanProcessing(true)", 1000);
