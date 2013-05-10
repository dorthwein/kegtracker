function openPopupWindow(url){
//	$(".jqxWindowIFrame").attr('src',url);		       
    $.ajax({
        url: url,
        type: 'GET',
        data: {ajax_load:1}
        //dataType: 'TEXT',
    }).done(function(data) {            
        $('#modal_content').html(data)		
		$("#modal_box").show();
	    var form_rules = []
	    // If password field exists
	    if($('#user_password').length > 0){
		    form_rules.push({input: '#user_password', message:'Required!', action: 'keyup, blur', rule: function (input, commit) {
		    	if($('#user_password_confirmation').val().length == 0 && input.val() != 0){
		    		return false;
		    	} else{
		    		return true;
		    	}
		    }});
		    form_rules.push({input: '#user_password_confirmation', message:'Required!', action: 'keyup, blur', rule: function (input, commit) {
		    	if($('#user_password').val().length == 0 && input.val() != 0){
		    		return false;
		    	}else
		    	return true;
		    }})
		    form_rules.push({ input: '#user_password_confirmation', message: 'Passwords doesn\'t match!', action: 'keyup, focus', rule: function (input, commit) {
		        // call commit with false, when you are doing server validation and you want to display a validation error on this field. 
		        if (input.val() === $('#user_password').val()) {
		            return true;
		        }		        
		        return false;
		    }});
		}

		$.each($('.required'), function(key, value){				
			var id = '#' + value.id	
			form_rules.push({input: id, message: 'Required!', action: 'keyup, blur', rule: function(input, commit){																	
				var element = $(id)
				if( $(element).val() == null || $(element).val() == 0 ){
					return false
				} else return true
			}})		
		})
	    
	    $('#modal_box').jqxValidator({rtl:true, rules: form_rules });				
	    $('#modal_box').jqxValidator('validate');	
        //setViews();
    })
	

	$('#page_view').addClass('modal-blur');
}

function jqxIntialize(){
	var theme = settings.theme		
	// Grid Column show/hide
// ***********************
// jqxGrid Functions
// ***********************	
	if($('.jqxGrid').length && 	$(".jqxGridColumnListBox").length){		
		var listSource = [];
		$.each( $('.jqxGrid').jqxGrid('columns'), function(key, item){			
			if(item['hidden'] == true)
				var check = false
			else {
				var check = true
			}

			listSource.push({ label: item.text, value: item.datafield, checked:check })
		})

	    $(".jqxGridColumnListBox").jqxListBox({
	    	source: listSource,
	    	height: 100, // jqxGridColumnListBoxHeight() - 20,
	    	width:'100%',
	    	theme: theme,
	    	checkboxes: true,
	    });
	   
	    $(".jqxGridColumnListBox").on('checkChange', function (event) {
	        if (event.args.checked) {
	            $(".jqxGrid").jqxGrid('showcolumn', event.args.value);
	        }
	        else {
	            $(".jqxGrid").jqxGrid('hidecolumn', event.args.value);
	        }
	    });	

	}	
	$('.jqxGridColumnListBoxToggle').on('click', function(){
		if( $('.jqxGridColumnListBoxToggle').hasClass('active') ){
			$('#gridOptionsExtended').hide();
			$('.jqxGridColumnListBoxToggle').removeClass('active');
		} else {
			$('#gridOptionsExtended').show();
			$('.jqxGridColumnListBoxToggle').addClass('active');
		}		
		setViews();
	})

//	$(".new").jqxButton({ theme: theme });
	$(".new").click(function () {
		var url = parseUrl(location)
		url = url + '/new'
		console.log(url + '<---');	
		openPopupWindow(url)
	});

//	$(".delete").jqxButton({ theme: theme });            
	$(".delete").click(function () {
		if(confirm('Are you sure you want to delete these records?')){
			var rowindexes = $('.jqxGrid').jqxGrid('getselectedrowindexes');
			var ids = []
			$.each(rowindexes, function(key, value){
				var rowdata = $('.jqxGrid').jqxGrid('getrowdata', value);
				ids.push(rowdata['_id'])
			})
			$.ajax({
				type: "DELETE",
				dataType : "JSON",
				url: parseUrl(location) + '/delete_multiple',
				data: { 
					ids: ids,
				},
			}).done(function( data ) {			
				window.dataAdapter.dataBind();
			});		        
		}
	});

	$(".restore").click(function () {
		if(confirm('Are you sure you want to restore these records?')){
			var rowindexes = $('.jqxGrid').jqxGrid('getselectedrowindexes');
			var ids = []
			$.each(rowindexes, function(key, value){
				var rowdata = $('.jqxGrid').jqxGrid('getrowdata', value);
				ids.push(rowdata['_id'])
			})
			$.ajax({
				type: "POST",
				dataType : "JSON",
				url: parseUrl(location) + '/restore_multiple',
				data: { 
					ids: ids,
				},
			}).done(function( data ) {			
				window.dataAdapter.dataBind();
			});		        
		}
	});

	// Button Processing/Action	
	// NEW BUTTON 
//	$(".excelExport").jqxButton({ theme: theme});
	$("body").on('click', '.excelExport', function () {	
		var target = $(this).attr('data-export');
		if(target == undefined){
			target = '.jqxGrid';
		}		
		$(target).jqxGrid('exportdata', 'csv', 'BreweryApps', true, null, true, system.server + '/system/export/jqx_csv.csv');

// The first parameter of the export method determines the export’s type – ‘xls’, ‘xml’, ‘html’, ‘json’, ‘tsv’ or ‘csv’.
// The second parameter is the file’s name.
// The third parameter is optional and determines whether to export the column’s header or not. Acceptable values are – true and false. By default, the exporter exports the columns header.
// The fourth parameter is optional and determines the array of rows to be exported. By default all rows are exported. Set null, if you want all rows to be exported.
// The last parameter is optional and determines the url of the export server. By default, the exporter is hosted on the jQWidgets website.		
	});
	

//	$(".jqxFilterToggle").jqxToggleButton({ theme: theme});
	$(".jqxFilterToggle").click(function () {
    	if ($(this).attr("disabled") != "disabled"){    		
	        var toggled = $(".jqxGrid").jqxGrid('filterable')	// $(this).jqxToggleButton('toggled');	        
	        if (toggled) {	            
				$(".jqxGrid").jqxGrid({filterable:false, showfilterrow:false})
				$('.jqxGrid').jqxGrid('clearfilters');
				$(".jqxGrid").jqxGrid('render');
				$(this).html('Filter Off');	        	

	        } else {	        	
	        	$(".jqxGrid").jqxGrid({filterable:true, showfilterrow:true})
				$(".jqxGrid").jqxGrid('render');	        	
	        	$(this).html('Filter On');	        		        	

	        }

	    }		           
	});


// ******************************
// jqxInput Formatting Functions
// ******************************
	$(".jqxInput").jqxInput({height: '20px', width: '200px', theme: theme });	
	$(".jqxNumberInput").jqxNumberInput({height: '20px', digits: 4, width: '200px', theme: theme});
	$(".jqxNumberInput.currency").jqxNumberInput({decimalDigits: 2, symbol: '$'})	
	$(".jqxButton").jqxButton({ theme: theme, width:75 });            

	$(".jqxDateTimeInput").jqxDateTimeInput({ width: '200px', height: '20px', theme: theme });
	$(".jqxDropDownList").jqxDropDownList({ source: {}, valueMember: 'value', displayMember: 'html', width: '200px',  height: '20px', theme: theme });	
	

	$(".jqxListBox").jqxListBox({ source: {}, valueMember: 'value', displayMember: 'html', width: '200px',  height: '200px', theme: theme });	

	$(".jqxToggle").jqxToggleButton({ theme: theme });
    $(".jqxToggle").bind('click', function () {    	    	    
    	if ($(this).attr("disabled") != "disabled"){
	        var toggled = $(this).jqxToggleButton('toggled');
	        if (toggled) {
	            $(this).val(1);
	            $(this).html('On');
	        }
	        else {
	        	$(this).val(0);
	        	$(this).html('Off');
	        }
	    }
    });

}	
